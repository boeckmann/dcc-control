unit uformtrain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, utrains, Types, LCLType, uformaddress;

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
    cbf9: TCheckBox;
    cbF10: TCheckBox;
    cbF11: TCheckBox;
    cbF12: TCheckBox;
    cbDCC14: TCheckBox;
    cbF0: TCheckBox;
    CheckGroup1: TCheckGroup;
    lblTrain: TLabel;
    lblSpeed: TLabel;
    rbForward: TRadioButton;
    rbBackward: TRadioButton;
    rgDirection: TRadioGroup;
    tbSpeed: TTrackBar;
    procedure cbDCC14Change(Sender: TObject);
    procedure cbF0Change(Sender: TObject);
    procedure cbFxChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure lblTrainClick(Sender: TObject);
    procedure rbBackwardChange(Sender: TObject);
    procedure rbForwardChange(Sender: TObject);
    procedure tbSpeedChange(Sender: TObject);

    constructor Create(AOwner: TComponent; addr: Integer); overload;
  private
    addr: Integer;
    alreadyShown: Boolean;
    cbFn: array[1..12] of TCheckBox;
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

  cbFn[1] := cbF1;
  cbFn[2] := cbF2;
  cbFn[3] := cbF3;
  cbFn[4] := cbF4;
  cbFn[5] := cbF5;
  cbFn[6] := cbF6;
  cbFn[7] := cbF7;
  cbFn[8] := cbF8;
  cbFn[9] := cbF9;
  cbFn[10] := cbF10;
  cbFn[11] := cbF11;
  cbFn[12] := cbF12;
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
  self.Caption:='Bedienpult ' + IntToStr(addr);
  lblTrain.Caption:='#' + IntToStr(addr);

end;

procedure TFormTrain.FormDeactivate(Sender: TObject);
begin
  Color := clDefault;
end;

procedure TFormTrain.FormHide(Sender: TObject);
begin
  { trains.SetActive(addr, false); }
end;

procedure TFormTrain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  fn: Integer;
begin
  if (Key >= VK_F1) and (Key <= VK_F12) and (Shift = []) then begin
    fn := Key-VK_F1+1;
    cbFn[fn].Checked := not cbFn[fn].Checked;
    Key := 0;
  end;
  if Key = VK_SPACE then begin
    FormMain.StopOrPowerOff;
    Key := 0;
  end;

end;

procedure TFormTrain.FormKeyPress(Sender: TObject; var Key: char);
begin

  if Key = #27 then begin
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

procedure TFormTrain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  tbSpeed.Position:=tbSpeed.Position - 1;
end;

procedure TFormTrain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  tbSpeed.Position:=tbSpeed.Position + 1;
end;

procedure TFormTrain.FormShow(Sender: TObject);
begin
  if not alreadyShown then begin
    trains.SetActive(addr, true);
    trains.SetDirection(addr, Forward);
    trains.SetFunction(addr, 0, false);
    alreadyShown := true;
  end;
end;

procedure TFormTrain.lblTrainClick(Sender: TObject);
begin
  { FormAddress.ShowModal; }
end;

procedure TFormTrain.rbBackwardChange(Sender: TObject);
begin
  trains.SetDirection(addr, Backward);
end;

procedure TFormTrain.rbForwardChange(Sender: TObject);
begin
  trains.SetDirection(addr, Forward);
end;

procedure TFormTrain.cbF0Change(Sender: TObject);
begin
  trains.SetFunction(addr, 0, cbF0.Checked);
end;

procedure TFormTrain.cbFxChange(Sender: TObject);
var
  cb: TCheckBox;
begin
  { TabOrder+1 als Funktionsnummer benutzen }
  cb := Sender as TCheckBox;
  trains.SetFunction(addr, cb.TabOrder+1, cb.Checked);
end;

procedure TFormTrain.FormActivate(Sender: TObject);
begin
  Color := clWhite;
end;

procedure TFormTrain.cbDCC14Change(Sender: TObject);
begin
  if cbDCC14.Checked then tbSpeed.Max:=14 else tbSpeed.Max:=28;
  trains.SetDCC14(addr, cbDCC14.Checked);
end;

end.

