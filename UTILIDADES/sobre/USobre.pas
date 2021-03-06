unit USobre;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TFormSobre = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Label1: TLabel;
    LBUsada: TLabel;
    LBLivre: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BitBtn1: TBitBtn;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    V: string;
    procedure PegaDados;
  public
    { Public declarations }
  end;

var
  FormSobre: TFormSobre;

implementation

{$R *.DFM}

procedure TFormSobre.FormCreate(Sender: TObject);
const
  InfoNum = 10;
  InfoStr: array[1..InfoNum] of string = ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks', 'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
var
  S: string;
  n, Len, i: DWORD;
  Buf: PChar;
  Value: PChar;
  InfoValores: array[1..InfoNum] of string;
begin
  S := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(S), n);
  if n > 0 then
  begin

    Buf := AllocMem(n);
 //   Memo1.Lines.Add('VersionInfoSize = ' + IntToStr(n));
    GetFileVersionInfo(PChar(S), 0, n, Buf);
    for i := 1 to InfoNum do
      if VerQueryValue(Buf, PChar('StringFileInfo\041604E4\' + InfoStr[i]), Pointer(Value), Len) then
        InfoValores[i]:= Value;
    FreeMem(Buf, n);
  end;
  ProductName.Caption:= InfoValores[8];
  Version.Caption:= 'Vers?o: '+InfoValores[3];//+ ' '+InfoValores[4];//'Vers?o 2.2.5.0 de (13/12/2002)';
  V:= 'Vers?o: '+InfoValores[3];
  Copyright.Caption:= 'Copyright '+InfoValores[5];
  PegaDados;
end;

procedure TFormSobre.FormActivate(Sender: TObject);
var
  MS: TMemoryStatus;
begin
  GlobalMemoryStatus(MS);
  LBUsada.Caption := FormatFloat('#,###" KB"', MS.dwTotalPhys / 1024);
  LBLivre.Caption := Format('%d %%', [MS.dwMemoryLoad]);
  PegaDados;
end;

procedure TFormSobre.PegaDados;
const
  InfoNum = 10;
  InfoStr: array[1..InfoNum] of string = ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks',
          'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
var
  S: string;
  n, Len, i: DWORD;
  Buf: PChar;
  Value: PChar;
  Pesquisa: TSearchRec;
begin
  Memo1.Lines.Clear;
  S := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(S), n);
  if n > 0 then
  begin
    Buf := AllocMem(n);
//    Memo1.Lines.Add('VersionInfoSize = ' + IntToStr(n));
    GetFileVersionInfo(PChar(S), 0, n, Buf);
    for i := 1 to InfoNum do
      if VerQueryValue(Buf, PChar('StringFileInfo\041604E4\' + InfoStr[i]),
         Pointer(Value), Len) then
        if Length(Value)>1 then
          Memo1.Lines.Add(InfoStr[i] + ' = ' + Value);
    if VerQueryValue(Buf, PChar('StringFileInfo\041604E4\' + InfoStr[3]),
       Pointer(Value), Len) then
    FreeMem(Buf, n);
  end
  else
    Memo1.Lines.Add('Nenhuma informa??o de vers?o encontrada');
  FindFirst(ParamStr(0),0,Pesquisa);
  Memo1.Lines.Add('Tamanho: '+FormatFloat('##,###,###', Pesquisa.Size)+' bytes');
  Memo1.Lines.Add('Data Compila??o: '+DateToStr(FileDateToDateTime(Pesquisa.Time)));
  Version.Caption:= V+ ' - '+DateToStr(FileDateToDateTime(Pesquisa.Time));
  Memo1.Lines.Add('Hora Compila??o: '+TimeToStr(FileDateToDateTime(PEsquisa.Time)));
  FindClose(Pesquisa);
end;
{
1.0.0.1 (16/09/2008) -> SOBREPONDO CURVAS POR CANAL.
1.0.0.2 (16/09/2008) -> POTENCIAL EVOCADO SSE.
1.0.0.3 (16/09/2008) -> Programa q expira
1.0.0.4 (16/09/2009) -> PESSE com prote??o no ini FILTRO ADP P1 = 0 OU 1
                        PEAUD com prote??o no ini FILTRO ADP P2 = 0 OU 1
                        PEVIS com prote??o no ini FILTRO ADP P3 = 0 OU 1
1.0.0.5 (27/02/2009) -> ONDA F corrigido problema d4e posicionamento de
                        sele??o de curvas na onda F
                        possibilita ativar/desativar promedio durante a estimula??o
1.0.0.6 (16/03/2009) -> Altera??o de configura??o do filtro notch
1.0.0.7 (20/03/2009) -> Corre??o da marca??o da estimula??o repetitiva
                        Corre??o do posicionamento inicial da selecao ondaF estimRep
                        Corre??o da lista de retorno de exame...
                        Corre??o do calculo da area
                        Corre??o da posicao dos dados no cabe?alho...
1.0.0.8 (23/03/2009) -> Corre??o da chamada a janela de medi??o de imped?ncia
                        Inserido Qtd telas para imprimir
                        Alterado configura??o da onda F para exibir sitio
                        Desenhar a letra depois da curva
1.0.0.9 (23/06/2009) -> Erro de protocolo na classe TCurva que calculava errado latencia e duracao de tempoJ diferentes na mesma tela
1.0.0.10 (27/07/2009)-> inserido a retirada do artefacto de estimulo
                        inserido o filtro Smothing em tempo de capta??o
                        inserido op??o de alterar a dura??o do estimulo de 0,01 em 0,01 ms
                        alterado algoritmo de marca??o autom?tica
1.0.0.11 (20/08/2009)-> PEVISUAL
1.0.0.11 (20/08/2009)-> Copia/Cola curva
                        Inverte Curva
                        Atualizado OnPaint das forms para poder desenhar ao abrir...
                        Inserido Tempo de Janela e Ganho Visual em todas as exibi??es de arquivos gravados
                        Aumentado o espa?o entre as curvas na estimula??o repetitiva
                        Comando para alterar o tempo de janela offline.
                     -> Velocidade na condu??o motora na tabela. Corrigido.
1.0.0.12 (20/11/2009)-> Implementa??o do PEAuditivo, altera??o do valor m?ximo de 1 bilhao para 1,7 bilhao
1.0.0.13 (14/12/2009)-> Implementa??o dE LIMITE PARA A SENOIDE EM 20000hZ 120 dB E RUIDO EM 15 dB
1.0.0.14 (03/03/2010)-> Aviso ao clicar em testagem sem nenhum paciente selecionado
                        Salvar automaticamente o paciente
1.0.0.15 (03/03/2010)-> Shift+M inprimindo

1.0.0.16 (23/03/2010)-> A TAB de escolha de pacientes foi desabilitada ao selecionar Paciente->Novo
                        Corrigido Acess Violation ao teclar Selecionar em Retorno de Paciente sem nenhum paciente selecionado
                        Corrigido Acess Violation ao teclar Selecionar em Retorno de Exame sem nenhum exame selecionado
                        Corrigido erro ao tentar importar exames de um CD
                        Retirados os botoes mais e menos zoom da janela de inspeciona telas gravadas
                        O Campo emails do cadastro de pacientes est? sendo limpo junto com os outros
                        Corrigido erro de n?o gravar os dados na curva quando a janela de preenchimento autom?tico estiver ativa
                        corrigido erro ao inserir uma curva em um exame ja gravado com o equipamento desligado(acess violation)
                        corrigido erro quando a op??o de exibir divis?es est? desligada, o programa n?o atualiza as marca??es corretamente
                        Corrigido Acess violation qdo o programa ? fechado durante uma capta??o
                        Corrigido Imprimir/inspecionar telas gravadas em um exame sem telas gravadas(floating point).
1.0.0.17 (08/09/2010)-> Inserida rotina de auto recupera??o para o painel USB
1.0.0.18 (13/09/2010)-> Alterado FPB de hardware para deixar o som da miografia mais agudo
                        Alterado a rotina de impress?o para inprimir retangulos nas janelas
1.0.0.19 (30/09/2010)-> Inserido op??o de ordena??o nas janelas de retorno de exame, retorno de paciente e gerencia
1.0.0.20 (12/09/2010)-> 12/11/2010 alterado para resolver problema do ganho mais baixo do vecon com firmware na vers?o 3
                        Foi criado um novo vetor de ganhos e o vetor antigo passou a ser apenas indices de ganhos.
1.0.0.21 (21/12/2010)-> INSERIDA PROTE??O PARA DISPARO DO PAINEL procedure TMainForm.InterpletaComando(var Mensagem: TMessage);
                        INSERIDO PROTE??O PROMEDIO EM procedure TCaptador.Capta;
1.0.0.22 (21/01/2011)-> Sequencia automatica abria janela de testagem corrigido
                        Laudo inserido no PDF
                        Revis?o da rotina de Filtros...implementamos a ida e volta
                        Ligar PA e PB de software individualmente
                        2?V por divisao - calibracao versao 4
                        filtro do Guido PB para decimacao 0 e 1 alterado para indice 2 10Khz
1.0.0.23 (09/01/2011)-> Novas interfaces para configura??o de Protocolo e Sequ?ncia autompatica(esta ultima fica no menu configura??es)
                        Inserido a op??o para configura??o dos filtros de Hardware.
                        insere nervos e sitios automaticamente, se configurado, na lista  na janela de escolhe NS
1.0.0.24 (11/01/2011)-> Interface com novos bot?es opcional em configura??es gerais do sistema
                        Corrigido pequenos problemas de posicionamento da tela ao abrir
                        Alterado  o m?todo de funcionamento da sequ?ncia autom?tica.
1.0.0.25 (25/02/2011)-> Inserido par e impar no PESSE, PAUD, PVIS
                        Inserido op??es de amaciamento e multiplicar junto ou separdo
                        Inserido diferenciacao por cores configuraveis
1.0.0.26 (02/03/2011)-> Inserido prote??o no execute da thread para falta de resposta para o comando Stop
                        Corrigido problema nos potenciais evocados relativos a enviar um desliga estimulador ao sair da capta??o
1.0.0.27 (11/03/2011)-> Corre??o da rotina de calibra??o no metodo execute da thread gerado pela monitora??o do stop
1.0.0.28 (09/03/2011)-> Inserido teste MUP (Rotina de aquisi??o, analise, impress?o e PDF.
1.0.0.29 (22/06/2011)-> Corrigido problema da medi??o de imped?ncia.
1.0.0.30 (27/06/2011)-> Inserido outro calculo com para obter melhor desemplenho na medi??o de imped?ncia
1.0.0.31 (26/07/2011)-> Corrigido problema de impress?o quando a tabela ocupa mais de uma folha.
1.0.0.32 (16/08/2011)-> Corrigido erro ao teclar Shift+0 para esconder as marcas.
1.0.0.33 (06/09/2011)-> Habilitado Amp Est para muap
1.0.0.34 (18/09/2011)-> retirado menu MUP
1.0.0.35 (19/01/2012)-> corrigido erro na qtd de colunas de uma linha da tabela unit: uimprimir linha 1208
1.0.0.36 (09/02/2012)-> corrigido erro de altera??o de dados de uma curva sem ter nenhuma selecionada. Se for estim Rep, onda F ou Mio, altera de todas as curvas
1.0.0.37 (13/03/2012)-> implementado vers?o para utiliza??o do estimulo ?nico com o firmware da vers?o 4
                        corrigido erro de impress?o da tabela linha MAIN linha 728
                        Otimiza??o do recurso da sequencia autom?tica
                        Form imprime telas: desabilita bot?es se n?o tiver nenhuma op??o checked
                        inserido uma caixa de dialogo para escolher onde salvar o PDF.
1.0.0.38 (22/04/2014)-> fun??o para exportar MUP para TXT(exame continuo)
}

end.

