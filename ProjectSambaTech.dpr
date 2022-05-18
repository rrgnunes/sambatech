program ProjectSambaTech;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {F_Main},
  dmDados in 'dmDados.pas' {dmGeral: TDataModule},
  frmHistorico in 'frmHistorico.pas' {F_Historico};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TF_Main, F_Main);
  Application.CreateForm(TdmGeral, dmGeral);
  Application.CreateForm(TF_Historico, F_Historico);
  Application.Run;
end.
