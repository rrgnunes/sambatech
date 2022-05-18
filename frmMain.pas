unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdAntiFreezeBase, IdAntiFreeze, dmDados,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, frmHistorico,
  FireDAC.Phys.SQLiteWrapper, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL;

type
  TF_Main = class(TForm)
    Panel1: TPanel;
    btnIniciar: TSpeedButton;
    Panel2: TPanel;
    Image1: TImage;
    Label1: TLabel;
    editUrl: TEdit;
    progressBar: TProgressBar;
    lblStatus: TLabel;
    btnFechar: TSpeedButton;
    btnCancelar: TSpeedButton;
    IdHTTP: TIdHTTP;
    dlgSave: TSaveDialog;
    btnLimpar: TSpeedButton;
    IdAntiFreeze: TIdAntiFreeze;
    lblPercentual: TLabel;
    btnHistorico: TSpeedButton;
    qryDownload: TFDQuery;
    procedure btnFecharClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure idHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure idHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure idHTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure btnLimparClick(Sender: TObject);
    procedure btnHistoricoClick(Sender: TObject);
  private
    _lDownloadAtivo: boolean;
    _sStatusDownload: string;
    _iCodigoHistorico: integer;
    { Private declarations }

    function RetornaPorcentagem(ValorMaximo, ValorAtual: real): string;
    function RetornaKiloBytes(ValorAtual: real): string;
  public
    { Public declarations }
  end;

var
  F_Main: TF_Main;

implementation

{$R *.dfm}

procedure TF_Main.btnCancelarClick(Sender: TObject);
begin
  if MessageDlg('Você tem certeza que deseja cancelar o download?',
    mtConfirmation, [mbyes, mbno], 0) = mryes then
  begin
    IdHTTP.Disconnect;
    lblStatus.Caption := '';
    lblPercentual.Caption := '';
    progressBar.Position := 0;
    _sStatusDownload := 'cancelado';
    _lDownloadAtivo := false;
    btnIniciar.Enabled := true;
    btnCancelar.Enabled := false;
  end;
end;

procedure TF_Main.btnFecharClick(Sender: TObject);
begin
  if _lDownloadAtivo then
  begin
    if MessageDlg
      ('Existe download ativos, deseja mesmo fechar a janela e cancelar o download?',
      mtConfirmation, [mbyes, mbno], 0) = mrNo then
    begin
      exit;
    end;

  end;

  IdHTTP.Disconnect;
  Close;
end;

procedure TF_Main.btnHistoricoClick(Sender: TObject);
var
  F_Historico: TF_Historico;
begin
  //
  F_Historico := TF_Historico.Create(self);
  F_Historico.ShowModal;
end;

procedure TF_Main.btnIniciarClick(Sender: TObject);
begin
  var
    fileDownload: TFileStream;
  begin
    btnIniciar.Enabled := false;
    btnCancelar.Enabled := true;
    _sStatusDownload := 'finalizado';
    _lDownloadAtivo := true;

    dlgSave.Filter := 'Arquivos' + ExtractFileExt(editUrl.Text) + '|*' +
      ExtractFileExt(editUrl.Text);
    dlgSave.FileName := 'Arquivo';
    if dlgSave.Execute then
    begin
      fileDownload := TFileStream.Create(dlgSave.FileName +
        ExtractFileExt(editUrl.Text), fmCreate);
      try
        btnIniciar.Enabled := false;

        try
          // Salva em banco novo download
          qryDownload.Close();
          qryDownload.SQL.Text :=
            'INSERT INTO logdownload(url,datainicio) VALUES(:url,:datainicio)';
          qryDownload.ParamByName('url').AsString := editUrl.Text;
          qryDownload.ParamByName('datainicio').AsDateTime := now;
          qryDownload.ExecSQL;
          qryDownload.Close;

          IdHTTP.Get(editUrl.Text, fileDownload);
        except
          on E: Exception do

        end;
      finally
        FreeAndNil(fileDownload);
      end;
    end;
  end;

end;

procedure TF_Main.btnLimparClick(Sender: TObject);
begin
  editUrl.Text := '';
end;

procedure TF_Main.FormShow(Sender: TObject);
begin
  _lDownloadAtivo := false;
  btnCancelar.Enabled := false;
  progressBar.Position := 0;

  dmGeral.conGeral.Close;
  dmGeral.conGeral.Params.Database := GetCurrentDir + '\\base.db';
  dmGeral.conGeral.Params.DriverID := 'SQLite';
  dmGeral.conGeral.open();

  _iCodigoHistorico := 0;

  IdHTTP.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(IdHTTP);
  IdHTTP.HandleRedirects := True;
end;

procedure TF_Main.idHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  progressBar.Position := AWorkCount;
  lblStatus.Caption := 'Baixando ... ' + RetornaKiloBytes(AWorkCount);
  lblPercentual.Caption := 'Download em ... ' + RetornaPorcentagem
    (progressBar.Max, AWorkCount);
end;

procedure TF_Main.idHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  progressBar.Max := AWorkCountMax;
end;

procedure TF_Main.idHTTPWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
var
  iCodigo: Int64;
begin
  progressBar.Position := 0;
  lblStatus.Caption := 'Download ' + _sStatusDownload + ' ...';
  lblPercentual.Caption := '';
  btnIniciar.Enabled := true;
  btnCancelar.Enabled := false;

  iCodigo := dmGeral.conGeral.GetLastAutoGenValue('logdownload');

  qryDownload.Close();
  if (_sStatusDownload = 'cancelado') then
    qryDownload.SQL.Text :=
      'UPDATE logdownload set datafim = :datafim,cancelado=''S'' where codigo=:codigo'
  else
    qryDownload.SQL.Text :=
      'UPDATE logdownload set datafim = :datafim where codigo=:codigo';

  qryDownload.ParamByName('datafim').AsDateTime := now;
  qryDownload.ParamByName('codigo').AsInteger := iCodigo;
  qryDownload.ExecSQL;
  qryDownload.Close;

end;

function TF_Main.RetornaPorcentagem(ValorMaximo, ValorAtual: real): string;
var
  resultado: real;
begin
  resultado := ((ValorAtual * 100) / ValorMaximo);
  Result := FormatFloat('0%', resultado);

end;

function TF_Main.RetornaKiloBytes(ValorAtual: real): string;
var
  resultado: real;
begin
  resultado := ((ValorAtual / 1024) / 1024);
  Result := FormatFloat('0.000 KBs', resultado);
end;

end.
