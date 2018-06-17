unit utrainpropframe;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls;

type

  { TTrainPropFrame }

  TTrainPropFrame = class(TFrame)
    cbF1_12: TCheckBox;
    cbS: TCheckBox;
    cbVisible: TCheckBox;
    edTrainName: TEdit;
    lblNum: TLabel;
  private

  public

  end;

implementation

{$R *.lfm}

end.

