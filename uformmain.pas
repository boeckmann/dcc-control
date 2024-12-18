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
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    rgPower: TRadioGroup;
    StatusBar1: TStatusBar;
    tbHalt: TToggleBox;
    procedure ButtonTrainClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure MenuItem3Click(Sender: TObject);
    procedure rgPowerSelectionChanged(Sender: TObject);
    procedure tbEStopChange(Sender: TObject);
    procedure tbHaltChange(Sender: TObject);
  private
    trainForms: array[1..8] of TFormTrain;
  public
    procedure SetCommError;
    procedure ActivateTrainForm(train: Integer);
    procedure StopOrPowerOff;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.StopOrPowerOff;
begin
  if tbHalt.Checked = false then tbHalt.Checked := true
  else rgPower.ItemIndex := 1;
end;

procedure TFormMain.tbEStopChange(Sender: TObject);
var
  btn: TToggleBox;
begin
  btn := Sender as TToggleBox;
  trains.SetEStop(btn.Checked);

  { btn.SelectNext(btn, true, false); }
end;


procedure TFormMain.tbHaltChange(Sender: TObject);
begin
  trains.SetEStop(tbHalt.Checked);
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  i: integer;
  ini: TIniFile;
  port: String;
begin
  ini := TIniFile.Create('settings.ini');
  port := ini.ReadString('COM', 'Port', '\\.\COM1');
  ini.Destroy;

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
begin
  trains.GeneratorReset;
  trains.SetTrackPower(false);
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then begin
    StopOrPowerOff;
    Key := 0;
  end
end;

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key in ['1'..'8'] then begin
    ActivateTrainForm(Ord(Key)-Ord('0'));
  end;
end;

procedure TFormMain.MenuItem3Click(Sender: TObject);
begin
  FormConfig.Show;
end;

procedure TFormMain.rgPowerSelectionChanged(Sender: TObject);
begin
  trains.SetTrackPower(rgPower.ItemIndex = 0);
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

