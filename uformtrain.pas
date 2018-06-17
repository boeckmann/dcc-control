unit uformtrain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls,
  utrains;

type

  { TFormTrain }

  TFormTrain = class(TForm)
    cbF1: TCheckBox;
    cbF2: TCheckBox;
    cbF3: TCheckBox;
    cbF4: TCheckBox;
    cbF5: TCheckBox;
    cbF6: TCheckBox;
    cbF7: TCheckBox;
    cbF8: TCheckBox;
    cbF0: TCheckBox;
    cbf9: TCheckBox;
    cbF10: TCheckBox;
    cbF11: TCheckBox;
    cbF12: TCheckBox;
    cbDCC14: TCheckBox;
    CheckGroup1: TCheckGroup;
    lblTrain: TLabel;
    lblSpeed: TLabel;
    rbForward: TRadioButton;
    rbBackward: TRadioButton;
    rgDirection: TRadioGroup;
    tbSpeed: TTrackBar;
    procedure cbDCC14Change(Sender: TObject);
    procedure cbF0Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure rbBackwardChange(Sender: TObject);
    procedure rbForwardChange(Sender: TObject);
    procedure tbSpeedChange(Sender: TObject);

    constructor Create(AOwner: TComponent; addr: Integer); overload;
  private
    addr: Integer;
    alreadyShown: Boolean;
  public

  end;

var
  FormTrain: TFormTrain;

implementation

uses
  uformmain;

{$R *.lfm}

{ TFormTrain }

constructor TFormTrain.Create(AOwner: TComponent; addr: Integer);
begin
  inherited Create(AOwner);
  KeyPreview:=true;
  self.addr := addr;

  alreadyShown := false;
end;

procedure TFormTrain.tbSpeedChange(Sender: TObject);
begin
  rgDirection.Enabled := tbSpeed.Position = 0;
  cbDCC14.Enabled := tbSpeed.Position = 0;

  trains.SetSpeed(addr, tbSpeed.Position);
  lblSpeed.Caption := IntToStr(tbSpeed.Position);
end;


procedure TFormTrain.FormCreate(Sender: TObject);
begin
  self.Caption:='Zug ' + IntToStr(addr);
  lblTrain.Caption:='#' + IntToStr(addr);

end;

procedure TFormTrain.FormHide(Sender: TObject);
begin
  trains.SetActive(addr, false);
end;

procedure TFormTrain.FormKeyPress(Sender: TObject; var Key: char);
begin

  if Key = #27 then begin
    FormMain.rbStop.Checked:=true;
  end;

  if Key = ' ' then begin
     tbSpeed.Position:=0;
  end;

  if Key = 'i' then begin
    tbSpeed.Position:=tbSpeed.Position + 1;
  end;

  if Key = 'k' then begin
    tbSpeed.Position:=tbSpeed.Position - 1;
  end;

  if (Key = 'j') and (tbSpeed.Position = 0) then begin
    if rbForward.Checked then rbBackward.Checked:=true
    else rbForward.Checked:=true;
  end;

  if Key = 'l' then begin
    cbF0.Checked := not cbF0.Checked;
  end;

  if Key in ['1'..'8'] then begin
    FormMain.ActivateTrainForm(Ord(Key)-Ord('0'));
  end;
end;

procedure TFormTrain.FormShow(Sender: TObject);
begin
  if not alreadyShown then begin
     trains.SetDirection(addr, Normal);
     trains.SetFunction(addr, 0, false);
     alreadyShown := true;
  end;
  trains.SetActive(addr, true);
end;

procedure TFormTrain.rbBackwardChange(Sender: TObject);
begin
  trains.SetDirection(addr, Backward);
end;

procedure TFormTrain.rbForwardChange(Sender: TObject);
begin
  trains.SetDirection(addr, Normal);
end;

procedure TFormTrain.cbF0Change(Sender: TObject);
begin
  trains.SetFunction(addr, 0, cbF0.Checked);
end;

procedure TFormTrain.cbDCC14Change(Sender: TObject);
begin
  if cbDCC14.Checked then tbSpeed.Max:=14 else tbSpeed.Max:=28;
  trains.SetDCC14(addr, cbDCC14.Checked);
end;

end.

