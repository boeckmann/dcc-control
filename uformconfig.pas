unit uformconfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  utrainpropframe;

type

  { TFormConfig }

  TFormConfig = class(TForm)
    TrainPropFrame1: TTrainPropFrame;
    TrainPropFrame2: TTrainPropFrame;
  private

  public

  end;

var
  FormConfig: TFormConfig;

implementation

{$R *.lfm}

end.

