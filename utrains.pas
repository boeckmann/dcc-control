unit utrains;

{$mode objfpc}{$H+}

{$if 1}
{$define COMM}
{$endif}

interface

uses
  Classes, SysUtils, Serial;

type

TDirection = (Forward, Backward);

TTrain = class
  addr: Integer;
  speed: Integer;
  direction: TDirection;
  functions: array[0..68] of Boolean;
  dcc14: Boolean;
public
  constructor Create;
  procedure Reset;
  procedure ResetSpeedAndFn;
end;

TTrains = class
  trains: array[1..127] of TTrain;
private
  serialHandle: LongInt;
  suppressCommands : Integer;
  function SendCommand(cmd: String): Boolean;
  function SendTrainCommand(addr: Integer; cmd: String): Boolean;
  function RecvAnswer(): Boolean;

  function SendSpeedDir(train: Integer; speed: Integer; dir: TDirection): Boolean;

public

  constructor Create(port: String);
  destructor Destroy; override;

  procedure Reset;
  procedure ResetSpeedAndFn;
  function GeneratorReset : Boolean;

  procedure PauseCommands;
  procedure ResumeCommands;

  function SetTrackPower(power: Boolean): Boolean;
  function SetEStop(stop: Boolean): Boolean;
  function SetSpeed(train: Integer; spd: Integer): Boolean;
  function SetDirection(train: Integer; dir: TDirection): Boolean;
  procedure SetFunction(train: Integer; num: Integer; f: Boolean);
  function GetFunction(train: Integer; num: Integer): Boolean;
  function SetDCC14(train: Integer; value: Boolean): Boolean;
  function SetActive(train: Integer; value: boolean): Boolean;
end;

var
  trains: TTrains;

const
  SER_TIMEOUT = 1000;

implementation

uses uformmain;

procedure TTrains.PauseCommands;
begin
  Inc(suppressCommands);
end;


procedure TTrains.ResumeCommands;
begin
  if suppressCommands > 0 then Dec(suppressCommands);
end;


function TTrains.RecvAnswer(): Boolean;
var
  answer: array[0..1] of Byte;

begin
  Result := True;

  if SuppressCommands = 0 then begin
    answer[0] := 0;
    {$IFDEF COMM}
    repeat
      if SerReadTimeout(serialHandle, answer, 1, SER_TIMEOUT) = 0 then begin
        Result := False;
      end;
    until (not Result) or (answer[0] = Ord('?'));
    if Result then begin
       if (SerReadTimeout(serialHandle, answer, 1, SER_TIMEOUT) = 0) or (answer[0] <> Ord('O')) then Result := False;
    end;
    {$ENDIF}
  end;

  if not Result then FormMain.SetCommError;
end;

function TTrains.SendCommand(cmd: String): Boolean;
var
  s: String;
begin
  if SuppressCommands = 0 then begin
    s := '!' + cmd + #13 + #10;

    {$IFDEF COMM}
    SerWrite(serialHandle, s[1], length(s));
    SerSync(serialHandle);
    {$ENDIF}
    Result := RecvAnswer();
  end else Result := true;

end;


function TTrains.SendTrainCommand(addr: Integer; cmd: String): Boolean;
var
  s: String;
begin
  if SuppressCommands = 0 then begin
    s := Format('!%d%s'+#13+#10, [addr, cmd]);

    {$IFDEF COMM}
    SerWrite(serialHandle, s[1], length(s));
    SerSync(serialHandle);
    {$ENDIF}
    Result := RecvAnswer();
  end else Result := true;
end;

constructor TTrains.Create(port: String);
var
  i: Integer;
begin
  for i := low(trains) to high(trains) do trains[i] := TTrain.Create;
  {$IFDEF COMM}
  serialHandle := SerOpen(port);
  if serialHandle = 0 then raise Exception.Create('can not open serial port ' + port);
  SerSetParams(serialHandle, 9600, 8, NoneParity, 1, []);
  {$ENDIF}
end;

destructor TTrains.Destroy;
var i : Integer;
begin
  for i := low(trains) to high(trains) do FreeAndNil(trains[i]);
end;

procedure TTrains.Reset;
var i: Integer;
begin
  SendCommand('R');
  for i := low(trains) to high(trains) do trains[i].Reset;
end;


procedure TTrains.ResetSpeedAndFn;
var i: Integer;
begin
  SendCommand('S');
  for i := low(trains) to high(trains) do trains[i].ResetSpeedAndFn;
end;


function TTrains.SetTrackPower(power: Boolean): Boolean;
begin
  if (power) then SendCommand('P+')
  else SendCommand('P-');

  Result := true;
end;


function TTrains.GeneratorReset : Boolean;
begin
  Result := SendCommand('R');
  Reset;
end;


function TTrains.SetEStop(stop: Boolean): Boolean;
begin
  if (stop) then SendCommand('H+')
  else SendCommand('H-');

  Result := true;
end;


function TTrains.SetDCC14(train: Integer; value: Boolean): Boolean;
begin
  trains[train].dcc14:=value;
  if value then SendTrainCommand(train, 'C+')
  else SendTrainCommand(train, 'C-');
  Result := true;
end;


function TTrains.SetActive(train: Integer; value: Boolean): Boolean;
begin
  trains[train].dcc14:=value;
  if value then SendTrainCommand(train, 'A+')
  else SendTrainCommand(train, 'A-');
  Result := true;
end;


function TTrains.SendSpeedDir(train: Integer; speed: Integer; dir: TDirection): Boolean;
var
  cmd: String;
  d: String;
begin
  if dir = Forward then d := 'V' else d := 'R';

  cmd := Format('%s%d', [d, speed]);

  SendTrainCommand(train, cmd);
  Result := true;
end;


function TTrains.SetSpeed(train: Integer; spd: Integer): Boolean;
begin
  with trains[train] do begin
    if speed <> spd then begin
      speed := spd;
      SendSpeedDir(train, speed, direction);
    end;
  end;
  Result := true;
end;


function TTrains.SetDirection(train: Integer; dir: TDirection): Boolean;
begin
  with trains[train] do begin
    if direction <> dir then begin
      direction := dir;
      SendSpeedDir(train, speed, direction);
    end;
  end;
  Result := true;
end;


procedure TTrains.SetFunction(train: Integer; num: Integer; f: Boolean);
var
  cmd: String;
  fs: String;
begin
  if (num <= 68) and (trains[train].functions[num] <> f) then begin
    trains[train].functions[num] := f;

    if f then fs := '+' else fs := '-';

    cmd := Format('F%.2d%s', [num, fs]);
    SendTrainCommand(train, cmd);
  end;
end;


function TTrains.GetFunction(train: Integer; num: Integer) : Boolean;
begin
  if num <= 68 then Result := trains[train].functions[num]
  else Result := false;
end;

constructor TTrain.Create;
begin
  Reset;
end;

procedure TTrain.Reset;
var i: Integer;
begin
  speed := 0;
  direction := Forward;
  for i := low(functions) to high(functions) do functions[i] := false;
  dcc14 := false;
end;

procedure TTrain.ResetSpeedAndFn;
var i: Integer;
begin
  speed := 0;
  for i := low(functions) to high(functions) do functions[i] := false;
end;

begin
end.

