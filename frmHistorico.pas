unit frmHistorico;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.Buttons, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, dmDados;

type
  TF_Historico = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnFechar: TSpeedButton;
    gridHistorico: TDBGrid;
    DataSource1: TDataSource;
    qryHistorico: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_Historico: TF_Historico;

implementation

{$R *.dfm}

procedure TF_Historico.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TF_Historico.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Limpar memoria
  Action := caFree;
  F_Historico := nil;
end;

procedure TF_Historico.FormCreate(Sender: TObject);
begin
  // garantia :D
  qryHistorico.Close;
  qryHistorico.Open();
end;

end.
