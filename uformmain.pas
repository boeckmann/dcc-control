unit uformmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, uformtrain, utrains;

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
    StatusBar1: TStatusBar;
    tbEStop: TToggleBox;
    procedure ButtonTrainClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbEStopChange(Sender: TObject);
  private
    trainForms: array[1..8] of TFormTrain;
  public
    procedure SetCommError;
    procedure ActivateTrainForm(train: Integer);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.tbEStopChange(Sender: TObject);
var
  btn: TToggleBox;
begin
  btn := Sender as TToggleBox;
  trains.SetEStop(btn.Checked);

  btn.SelectNext(btn, true, false);
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i:=low(trainForms) to high(trainForms) do begin
    trainForms[i] := TFormTrain.Create(self, i);
  end;

end;

procedure TFormMain.ButtonTrainClick(Sender: TObject);
var
  btn: TButton;
begin
  btn := Sender as TButton;
  trainForms[btn.Tag].Show;
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

