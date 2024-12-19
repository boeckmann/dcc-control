unit uformmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, Menus, ExtCtrls, ActnList, uformtrain, utrains, uformconfig,
  LCLType, Buttons, inifiles;

type

  { TFormMain }

  TFormMain = class(TForm)
    BtnT1: TButton;
    BtnT2: TButton;
    BtnT3: TButton;
    BtnT4: TButton;
    BtnT5: TButton;
    BtnT6: TButton;
    BtnT7: TButton;
    BtnT8: TButton;
    ImageList1: TImageList;
    ImageList2: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    sbPower: TSpeedButton;
    sbPause: TSpeedButton;
    sbEOff: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure ButtonTrainClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure MenuItem3Click(Sender: TObject);
    procedure sbEOffClick(Sender: TObject);
    procedure sbPauseClick(Sender: TObject);
    procedure sbPowerClick(Sender: TObject);
  private
    trainForms: array[1..8] of TFormTrain;
    iniFile: TIniFile;
  public
    procedure SetCommError;
    procedure ActivateTrainForm(train: Integer);
    procedure ActivateEOff;
    procedure ReleaseEOff;
    procedure ActivatePause;
    procedure ReleasePause;
    procedure TogglePause;
    procedure ActivatePower;
    procedure ReleasePower;
    procedure TogglePower;

  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }


procedure TFormMain.ActivateEOff;
var i : Integer;
begin
  trains.SetTrackPower(false);
  trains.ResetSpeedAndFn;

  trains.PauseCommands;  { prevent sending commands to generator while }
                         { updating GUI }

  sbEOff.Down := true;

  sbPower.Down := false;
  sbPower.Enabled := false;
  sbPause.Down := false;
  sbPause.Enabled := false;

  for i := low(trainForms) to high(trainForms) do begin
    trainForms[i].EnableControls(false);
    trainForms[i].ResetSpeedAndFn;
  end;

  trains.ResumeCommands;
end;


procedure TFormMain.ReleaseEOff;
var i : Integer;
begin
  if sbEOff.Down then begin
    sbEOff.Down := false;
    sbPower.Enabled := true;
    sbPause.Enabled := true;

    for i := low(trainForms) to high(trainForms) do begin
      trainForms[i].EnableControls(true);
    end;
  end;
end;


procedure TFormMain.ActivatePause;
begin
  if not sbEOff.Down then begin
    trains.SetEStop(true);
    sbPause.Down := true;
  end;
end;


procedure TFormMain.ReleasePause;
begin
  if not sbEOff.Down then begin
     trains.SetEStop(false);
     sbPause.Down := false;
  end;
end;


procedure TFormMain.ActivatePower;
begin
  if not sbEOff.Down then begin
     trains.SetTrackPower(true);
     sbPower.Down := true;
  end;
end;


procedure TFormMain.ReleasePower;
begin
  if not sbEOff.Down then begin
    trains.SetTrackPower(false);
    sbPower.Down := false;
  end;
end;


procedure TFormMain.TogglePause;
begin
  if sbPause.Down then ReleasePause else ActivatePause;
end;


procedure TFormMain.TogglePower;
begin
  if sbPower.Down then ReleasePower else ActivatePower;
end;


procedure TFormMain.FormCreate(Sender: TObject);
var
  i: integer;
  port: String;
begin
  iniFile := TIniFile.Create('settings.ini');
  port := iniFile.ReadString('COM', 'Port', '\\.\COM1');

  try
    trains := TTrains.Create(port);
    trains.SetTrackPower(false);
    trains.GeneratorReset;
  except on
  e: Exception do begin
    Application.MessageBox(PChar(e.Message), 'Error');
    Application.Terminate;
    end
  end;
  KeyPreview:=true;

  for i:=low(trainForms) to high(trainForms) do begin
    trainForms[i] := TFormTrain.Create(self, i);
  end;

end;


procedure TFormMain.FormDestroy(Sender: TObject);
var i : Integer;
begin
  trains.GeneratorReset;
  trains.SetTrackPower(false);

  for i:=low(trainForms) to high(trainForms) do begin
    FreeAndNil(trainForms[i]);
  end;

  FreeAndNil(trains);
  iniFile.Destroy;
end;


procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then begin
    ActivateEOff;
    Key := 0;
  end
end;


procedure TFormMain.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #27 then begin
    ReleaseEOff;
  end;

  if Key in ['s'] then begin
    TogglePower;
  end
  else if Key in ['p'] then begin
    TogglePause;
  end
  else if Key in ['1'..'8'] then begin
    ActivateTrainForm(Ord(Key)-Ord('0'));
  end;
end;


procedure TFormMain.MenuItem3Click(Sender: TObject);
begin
  FormConfig.Show;
end;


procedure TFormMain.sbEOffClick(Sender: TObject);
begin
  if sbEOff.Down then ActivateEOff else ReleaseEOff;
end;


procedure TFormMain.sbPauseClick(Sender: TObject);
begin
  if sbPower.Down then ActivatePause else ReleasePause;
end;


procedure TFormMain.sbPowerClick(Sender: TObject);
begin
  if sbPower.Down then ActivatePower else ReleasePower;
end;


procedure TFormMain.ButtonTrainClick(Sender: TObject);
var
  btn: TButton;
begin
  btn := Sender as TButton;
  ActivateTrainForm(btn.Tag);
end;


procedure TFormMain.SetCommError;
begin
  statusbar1.Panels[0].Text:='Com ERROR!';
end;


procedure TFormMain.ActivateTrainForm(train: Integer);
begin
  trainForms[train].Show;
  trainForms[train].SetFocus;
end;

end.

