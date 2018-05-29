unit utrains;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Serial;

type

TDirection = (Normal, Backward);

TTrain = class
  speed: Integer;
  direction: TDirection;
  functions: array[0..12] of Boolean;
  dcc14: Boolean;
public
  constructor Create;
end;

TTrains = class
  trains: array[1..127] of TTrain;
private
  serialHandle: LongInt;
  function SendCommand(cmd: String): Boolean;
  function SendTrainCommand(addr: Integer; cmd: String): Boolean;
  function RecvAnswer(): Boolean;

  function SendSpeedDir(train: Integer; speed: Integer; dir: TDirection): Boolean;

public
  constructor Create;

  function SetEStop(stop: Boolean): Boolean;
  function SetSpeed(train: Integer; speed: Integer): Boolean;
  function SetDirection(train: Integer; dir: TDirection): Boolean;
  function SetFunction(train: Integer; num: Integer; f: Boolean): Boolean;
  function SetDCC14(train: Integer; value: Boolean): Boolean;
  function SetActive(train: Integer; value: boolean): Boolean;
end;

var
  trains: TTrains;

implementation

uses uformmain;

function TTrains.RecvAnswer(): Boolean;
var
  answer: String;

begin
  SetLength(answer, 10);
  answer[1] := ' ';
  repeat
    if SerRead(serialHandle, answer[1], 1) = 0 then continue;
    WriteLn('>' + answer[1]);
  until answer[1] = '?';
  while SerRead(serialHandle, answer[2], 1) = 0 do;
  WriteLn('!' + answer[2]);

  Result := answer[2] = 'O';

  if Result = false then FormMain.SetCommError;
end;

function TTrains.SendCommand(cmd: String): Boolean;
var
  s: String;
begin
  s := '!' + cmd + #13 + #10;

  Write(s);
  SerWrite(serialHandle, s[1], length(s));
  SerSync(serialHandle);

  Result := RecvAnswer();
end;


function TTrains.SendTrainCommand(addr: Integer; cmd: String): Boolean;
var
  s: String;
begin
  s := Format('!%.3d%s'+#13+#10, [addr, cmd]);

  Write(s);
  SerWrite(serialHandle, s[1], length(s));
  SerSync(serialHandle);

  Result := RecvAnswer();
end;

constructor TTrains.Create;
var
  i: Integer;
begin
  for i := low(trains) to high(trains) do trains[i] := TTrain.Create;
  serialHandle := SerOpen('/dev/ttyACM0');
  SerSetParams(serialHandle, 9600, 8, NoneParity, 1, []);
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
  if dir = Normal then d:= 'V' else d:='R';

  cmd := Format('%s%.2d', [d, speed]);

  SendTrainCommand(train, cmd);
  Result := true;
end;


function TTrains.SetSpeed(train: Integer; speed: Integer): Boolean;
begin
     trains[train].speed := speed;
     SendSpeedDir(train, speed, trains[train].direction);

     Result := true;
end;


function TTrains.SetDirection(train: Integer; dir: TDirection): Boolean;
begin
  trains[train].direction:=dir;
  SendSpeedDir(train, trains[train].speed, dir);

  Result := true;
end;

function TTrains.SetFunction(train: Integer; num: Integer; f: Boolean): Boolean;
var
  cmd: String;
  fs: String;
begin
  trains[train].functions[num] := f;

  if f then fs := '+' else fs := '-';

  cmd := Format('F%.2d%s', [num, fs]);
  SendTrainCommand(train, cmd);

  Result := true;
end;

constructor TTrain.Create;
var
  i: Integer;
begin
  speed := 0;
  direction := Normal;
  for i := low(functions) to high(functions) do functions[i] := false;
  dcc14 := false;
end;

begin
  trains := TTrains.Create;
end.

