program DCCEasyControl;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uformmain, uformtrain, utrains, uformconfig, utrainpropframe,
uformaddress
  { you can add units after this };

{$R *.res}

begin
  Application.Scaled:=True;
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormConfig, FormConfig);
  Application.CreateForm(TFormAddress, FormAddress);
  Application.Run;
end.

