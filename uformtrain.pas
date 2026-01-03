unit uformtrain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, utrains, Types, LCLType, Buttons;

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
    cbF9: TCheckBox;
    cbF10: TCheckBox;
    cbF11: TCheckBox;
    cbF12: TCheckBox;
    cbDCC14: TCheckBox;
    cbF0: TCheckBox;
    ImageList1: TImageList;
    lblFn: TLabel;
    lblTrain: TLabel;
    lblSpeed: TLabel;
    panelFn: TPanel;
    sbF1: TSpeedButton;
    sbF13: TSpeedButton;
    sbF25: TSpeedButton;
    sbF37: TSpeedButton;
    sbF49: TSpeedButton;
    sbF61: TSpeedButton;
    sbForward: TSpeedButton;
    sbBackward: TSpeedButton;
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
    procedure sbBackwardClick(Sender: TObject);
    procedure sbForwardClick(Sender: TObject);
    procedure sbFxClick(Sender: TObject);
    procedure tbSpeedChange(Sender: TObject);

    constructor Create(AOwner: TComponent; addr: Integer); overload;
  private
    formNum: Integer;
    addr: Integer;
    alreadyShown: Boolean;
    cbFn: array[1..12] of TCheckBox;
    sbFn: array[1..6] of TSpeedButton;
    controlsEnabled : Boolean;
    fnBase : Integer; { erste Funktionsnummer von ausgewaehlter Funktionsseite }
    procedure UpdateFxControls(fxGroup : Integer);
    function FxSbToGroup(Sender: TObject) : Integer;
    procedure ChangeDirection;
    function CbFnToNum(cb: TCheckBox) : Integer;
    procedure SelectNextFnGroup;
  public
    procedure ResetSpeedAndFn;
    procedure EnableControls(enable: Boolean);
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
  formNum := addr;
  self.addr := addr;
  alreadyShown := false;
  controlsEnabled := true;
  fnBase := 0;

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

  sbFn[1] := sbF1;
  sbFn[2] := sbF13;
  sbFn[3] := sbF25;
  sbFn[4] := sbF37;
  sbFn[5] := sbF49;
  sbFn[6] := sbF61;
end;


procedure TFormTrain.EnableControls(enable: Boolean);
var i : Integer;
begin
  controlsEnabled := enable;
  tbSpeed.Enabled := enable;
  sbForward.Enabled := enable;
  sbBackward.Enabled := enable;
  cbDCC14.Enabled := enable;
  cbF0.Enabled := enable;
  for i := low(cbFn) to high(cbFn) do cbFn[i].Enabled := enable;

end;


procedure TFormTrain.ResetSpeedAndFn;
var i : Integer;
begin
  tbSpeed.Position := 0;
  cbF0.Checked := false;
  for i := low(cbFn) to high(cbFn) do cbFn[i].Checked := false;
end;


procedure TFormTrain.tbSpeedChange(Sender: TObject);
begin
  sbForward.Enabled := (tbSpeed.Position = 0) or sbForward.Down;
  sbBackward.Enabled := (tbSpeed.Position = 0) or sbBackward.Down;
  cbDCC14.Enabled := tbSpeed.Position = 0;

  trains.SetSpeed(addr, tbSpeed.Position);
  lblSpeed.Caption := IntToStr(tbSpeed.Position);
end;


procedure TFormTrain.FormCreate(Sender: TObject);
begin
  Left := ScaleDesignToForm(16) + (addr-1) * (ScaleDesignToForm(Width + 16));
  if Left + ScaleDesignToForm(Width) > screen.Width then Left := screen.Width - ScaleDesignToForm(Width);
  Caption:='Bedienpult ' + IntToStr(addr);
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
    if controlsEnabled then begin
      fn := Key-VK_F1+1;
      if fn + fnBase <= 68 then cbFn[fn].Checked := not cbFn[fn].Checked;
    end;
    Key := 0;
  end;
  if Key = VK_SPACE then begin
    FormMain.ActivateEOff;
    Key := 0;
  end;
  if Key = VK_TAB then begin
    SelectNextFnGroup;
    Key := 0;
  end;
  if Key = VK_UP then begin
    tbSpeed.Position:=tbSpeed.Position + 1;
    Key := 0;
  end;
  if Key = VK_DOWN then begin
    tbSpeed.Position:=tbSpeed.Position - 1;
    Key := 0;
  end;
  if Key = VK_RIGHT then begin
    if (tbSpeed.Position = 0) and (sbBackward.Down = true) then begin
      sbForward.Down := true;
      ChangeDirection;
    end;
    Key := 0;
  end;
  if Key = VK_LEFT then begin
    if (tbSpeed.Position = 0) and (sbForward.Down = true) then begin
      sbBackward.Down := true;
      ChangeDirection;
    end;
    Key := 0;
  end;
end;


procedure TFormTrain.FormKeyPress(Sender: TObject; var Key: char);
begin

  if controlsEnabled then begin

    if Key in ['i', 'I'] then begin
      tbSpeed.Position:=tbSpeed.Position + 1;
    end;

    if Key in ['k', 'K'] then begin
      tbSpeed.Position:=tbSpeed.Position - 1;
    end;

    if (Key in ['j', 'J']) and (tbSpeed.Position = 0) then begin
      if sbForward.Down then sbBackward.Down:=true
      else sbForward.Down:=true;
      ChangeDirection;
    end;

    if Key in ['l', 'L'] then begin
      cbF0.Checked := not cbF0.Checked;
    end;

    if Key in ['h', 'H'] then begin
      tbSpeed.Position := 0;
    end;

    if Key in ['s', 'S'] then begin
       FormMain.TogglePower;
    end;

    if Key in ['p', 'P'] then begin
       FormMain.TogglePause;
    end;
  end;

  if Key in ['1'..'8'] then begin
    FormMain.ActivateTrainForm(Ord(Key)-Ord('0'));
  end;
end;


procedure TFormTrain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if controlsEnabled then tbSpeed.Position:=tbSpeed.Position - 1;
end;


procedure TFormTrain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
    if controlsEnabled then tbSpeed.Position:=tbSpeed.Position + 1;
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

procedure TFormTrain.sbBackwardClick(Sender: TObject);
begin
  ChangeDirection;
end;

procedure TFormTrain.sbForwardClick(Sender: TObject);
begin
  ChangeDirection;
end;


procedure TFormTrain.ChangeDirection;
begin
  if sbForward.Down then trains.SetDirection(addr, Forward)
  else trains.SetDirection(addr, Backward);
end;


procedure TFormTrain.UpdateFxControls(fxGroup : Integer);
var i : Integer;
begin
  fnBase := fxGroup * 12;

  for i := low(cbFn) to high(cbFn) do begin
    cbFn[i].Visible := i + fnBase <= 68;
    cbFn[i].Caption := 'F' + IntToStr(i + fnBase);
    cbFn[i].Checked := trains.GetFunction(addr, i + fnBase);
  end;
end;

function TFormTrain.CbFnToNum(cb: TCheckBox) : Integer;
var i : Integer;
begin
  Result := 0;
  for i := low(cbFn) to high(cbFn) do if cb = cbFn[i] then Result := i;
end;

function TFormTrain.FxSbToGroup(Sender: TObject) : Integer;
begin
  Result := 0;
  if Sender = sbF13 then Result := 1
  else if Sender = sbF25 then Result := 2
  else if Sender = sbF37 then Result := 3
  else if Sender = sbF49 then Result := 4
  else if Sender = sbF61 then Result := 5;
end;

procedure TFormTrain.SelectNextFnGroup;
var page : Integer;
begin
  page := (fnBase div 12 + 1) mod 6;
  sbFn[page+1].Down := true;
  UpdateFxControls(page);
end;

procedure TFormTrain.sbFxClick(Sender: TObject);
begin
  UpdateFxControls(FxSbToGroup(Sender));
end;


procedure TFormTrain.cbF0Change(Sender: TObject);
begin
  trains.SetFunction(addr, 0, cbF0.Checked);
end;


procedure TFormTrain.cbFxChange(Sender: TObject);
var
  cb: TCheckBox;
begin
  cb := Sender as TCheckBox;
  trains.SetFunction(addr, fnBase + CbFnToNum(cb), cb.Checked);
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

