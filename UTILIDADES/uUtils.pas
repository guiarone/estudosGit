unit uUtils;

interface

uses
  {WinProcs, }SysUtils, Consts, Windows, Vcl.Forms,
  uIniArq;

const
//nome do arquivo de configuracoes
  NOMEARQCONFIG = 'CONFIG.INI';
//constantes usadas para configuração de interface de acordo com tipo do exame
  QTD_TIPO_EXAME = 7;
  te_EEG = 0; te_MAPA = 1;te_PSG = 2; te_VEEG = 3; te_VPSG = 4; te_Monitor = 5; te_IntraOper = 6;
  TIPO_EXAME    : array[0..pred(QTD_TIPO_EXAME)] of integer = (te_EEG, te_MAPA, te_PSG, te_VEEG, te_VPSG, te_Monitor, te_IntraOper);
  TIPO_EXAME_STR: array[0..pred(QTD_TIPO_EXAME)] of string  = ('EEG' , 'MAPA' , 'PSG' , 'VEEG' , 'VPSG' , 'Monitor' , 'IntraOper');
//tempos de janela para PSG
  QTD_PSG_VELS = 9;
  PSG_Vels: array[0..pred(QTD_PSG_VELS)] of integer = (10,15,20,30,60,120,180,300,900);
//
type
//tipos de string básicos para headers e cadastros
  TStr50 = string[50];
  TStr30 = string[30];
  TStr20 = String[20];
  TStr10 = String[10];
  TStr08 = String[08];
  TStr05 = String[05];
  TStr02 = string[02];
//
  TregPaciente = packed record
    codigo      : TStr05;//06
    nome        : TStr50;//51
    nascimento  : TStr08;//09
    sexo        : TStr02;//03
    lateralidade: TStr02;//03
    documento   : TStr30;//31
    endereco    : TStr50;//51
    complemento : TStr30;//31
    bairro      : TStr30;//31
    cidade      : TStr30;//31
    uf          : TStr02;//03
    cep         : TStr08;//09
    telefone1   : Tstr20;//21
    telefone2   : Tstr20;//21
    email       : Tstr50;//51
  end;//
//
  TregExame = packed record
    codigo      : TStr02;//03
    data        : TStr08;//09
    hora        : TStr08;//09
    peso        : TStr10;//11
    altura      : TStr10;//11
    convenio    : TStr30;//31
    solicitante : TStr50;//51
    medicacao   : TStr50;//51
    tipoExame   : TStr02;//03
    numMaquina  : TStr10;//11
    nomeMaquina : TStr50;//51
  end;//
//
  TregCanal = packed record
    numero      : smallint;//02
    nome        : TStr20;////21
    unidade     : TStr20;////21
    corteInf    : double;////08
    corteSup    : double;////08
    freqNotch   : integer;///04
    valorCalib  : single;////04
    freqAm      : single;////04
  end;//

var
  config_INI: TIniArq;

  function GetTipoExameInt(valor: string) : integer;
  function GetTipoExameStr(valor: integer): string;
  //
  procedure GravaPosicaoForm(f: TForm);
  procedure LePosicaoForm(f: TForm);
implementation

function GetTipoExameInt(valor: string) : integer;
var
  i: Integer;
begin
  i:= -1;
  while i < QTD_TIPO_EXAME do
  begin
    inc(i);
    if TIPO_EXAME_STR[i] = valor then
      break;
  end;
  result:= i;
end;

function GetTipoExameStr(valor: integer): string;
begin
  if (valor > 0) and (valor < QTD_TIPO_EXAME) then
    result:= TIPO_EXAME_STR[valor]
  else
    result:= '';
end;

procedure GravaPosicaoForm(f: TForm);
begin
  config_INI.GravaInteiro(f.Name, 'Top', f.Top);
  config_INI.GravaInteiro(f.Name, 'Left', f.Left);
end;

procedure LePosicaoForm(f: TForm);
var
  meuTop, meuLeft: integer;
begin
  meuTop:=  config_INI.LeInteiro(f.Name, 'Top', -1);
  meuLeft:= config_INI.LeInteiro(f.Name, 'Left', -1);
  if (meuTop > -1) and (meuTop < Screen.Height-10 )then
    if (meuLeft > -1) and (meuLeft < Screen.Width-10 )then
    begin
      f.Top:= meuTop;
      f.Left:= meuLeft;
    end;
end;

end.
