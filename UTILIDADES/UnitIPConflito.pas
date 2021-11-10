unit UnitIPConflito;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormIPConflito = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IPMaquina,IPIni : string;
    Status : integer;
  end;

var
  FormIPConflito: TFormIPConflito;

implementation

{$R *.dfm}

procedure TFormIPConflito.FormCreate(Sender: TObject);
begin
  Caption := 'Alerta de Configuração';
  Label1.Caption := '';
end;


procedure TFormIPConflito.FormActivate(Sender: TObject);
begin
  if Status = -1  then
  begin
    Label1.Caption:= 'A configuração do sistema no arquivo EEGCaptacoes.ini usa o endereço de IP: '+ IPIni + #10+#13+
                   'Este endereço não está ativo nesse computador. Verifique a conexão com o equipamento.';
  end;
  if Status = -2  then
  begin
    Label1.Caption:= 'A configuração do sistema no arquivo EEGCaptacoes.ini usa o endereço de IP: '+ IPIni + #10+#13+
                   'Este endereço não está disponível nesse computador. Considere corrigir a configuração do equipamento.';
  end;
end;

end.
