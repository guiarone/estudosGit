unit uFuncoes;

interface

uses
  Controls, Classes, windows, Graphics, Forms, SysUtils, Dialogs, Gauges, ShellApi;

type
  THeaderEMF = packed record
    iType         : DWORD;// Record type EMR_HEADER.
    nSize         : DWORD;// Record size in bytes. This may be greater
                          // than the sizeof(ENHMETAHEADER).
    rclBounds     : TRect;// Inclusive-inclusive bounds in device units.
    rclFrame      : TRect;// Inclusive-inclusive Picture Frame of
                          // metafile in .01 mm units.
    dSignature    : DWORD;// Signature.  Must be ENHMETA_SIGNATURE.

    nVersion      : DWORD;// Version number.
    nBytes        : DWORD;// Size of the metafile in bytes.
    nRecords      : DWORD;// Number of records in the metafile.
    nHandles      : WORD; // Number of handles in the handle table.
                          // Handle index zero is reserved.
    sReserved     : WORD; // Reserved.  Must be zero.
    nDescription  : DWORD;// Number of chars in the unicode description string.
                          // This is 0 if there is no description string.

    offDescription: DWORD;// Offset to the metafile description record.
                          // This is 0 if there is no description string.
    nPalEntries   : DWORD;// Number of entries in the metafile palette.
    szlDevice     : SIZE; // Size of the reference device in pixels.
    szlMillimeters: SIZE; // Size of the reference device in millimeters.
  end;

  function FormataEspacoLivre(BKMGT: byte; unidade: string): string;
  function GetDadosEMF(nomeArq: string): THeaderEMF;
  function  CalculaRMS(VetorD: array of double; qtdptos: integer): double;
  function  AddBackSlash(S: string): string;
  function  ApagaArquivo(Caminho: string): boolean;
  function  apagaarquivos(mascara:string):integer;
  function  CalculaIdade(Data2, Data1: String):String;
  function  CalculaIdade2(Data2, Data1: String):integer;
  function  CompletaComEspacos( S: String; Tam: Integer ): String;
  function  CopiaArquivo(Origem, Destino: string): boolean;
  function  CopiaArquivo2(Origem, Destino: string): boolean;
  function  CopiaArquivoNova(Origem, Destino: string): integer;
  function  DataValida(AAAAMMDD: String): Boolean;
  function  DesformataData(DD_MM_AAAA: String): String;
  function  Dir(Mask: String; Attr: Integer): TStringList;
  Procedure Diret(Mask: string; Attr: integer; var Lista: TStringList);
  function  FormataData(AAAAMMDD: String): String;
  function  FormataData2D(AAAAMMDD: String): String;
  function  DesformataTempo(HH_MM_SS:string): integer;
  function  FormataTempo(Segundos: Integer): String;overload;
  function  FormataTempo(Segundos: Double): String;overload;
  function  GetCodUnidade(LetraUnidade: char): byte;
  function getEspacoLivre(Destino: string): int64;
  function  getFileSize(Arquivo: string): integer;
  function  getTamdir(Caminho: string): double;
  function  IdadeExtenso(Data2, Data1: String): String;
  Procedure pegaArq(caminho:string;var lis:TStringList);
  procedure ProcuraArquivos(Caminho,Nome: string; var aL:TStringList; crono: boolean = false);
  procedure ProcuraPastas(Caminho,Nome: string; var aL:TStringList);
  function  RetiraEspacos( S: String): String;
  function  RetiraEspacosDoFinal( S: String): String;
  function  RetornaEspacoLivre(S: string): int64;
  function  StrZero(Num:int64; Tam: byte): String;
  function  testastringnumerica(sa: string): boolean;
  function  testastringNumInt(sa: string): boolean;
  function  RetiraCaracterInvalido(sa: string): string;
  function  TempoEmSegundos(hh_mm_ss: string): integer;
  function  textotofloat(sa:string):double;
  function EsperaMS(tempo: word): boolean;
  procedure CopiaArquivoComGauge(Source, Dest: String; var G: TGauge);
  procedure JuntaArquivoComGauge(Arquivo, Origem: String; var Gtot, Gparc: TGauge);
  procedure DivideArquivoComGauge(Arquivo, Destino: String; var Gtot, Gparc: TGauge);
  function GetTamArquivo(narq: string): int64;
  function Diferenca_em_Segundos_hhmmss(horaini,horafim:string):integer;
  function PoeNaLixeira (Handle:tHandle;nomearq:string):boolean;//tem que incluir ShellApi no uses
  function ResumeTamanhoEMDisco(V: int64): string;
  FUNCTION PrinterOnLine: BOOLEAN;
  function Exibemsg(msg: string): integer;
//  function CalculaFrequenciaCard(Vet: array of smallint; amstela, TxAm:smallint): Single;
  function DescobreVersaoWindows: byte;
///////////////////
  function FormataCPF_CNPJ(S: string): string;
  function ValorRealporEstenso(valor: Single): String;
  procedure AcertaDivisaoComDizima(Valor: string; Qtd: Smallint; var Retorno1,Retorno2: double);
  function ValidaCPF(num: string): boolean;
//  function ValidaCNPJ(sCNPJ: string; MostraMsg: boolean = true): boolean;
  function CaptureScreenRect(aRect: TRect; aHandle: THandle): TBitmap;
  Function DesvioPadrao(vet : array of double):double;
  Function Media(vet : array of double):double;overload;
  Function Media(vet : array of single):single;overload;
  Function Media(vet : array of integer):single;overload;
  Function VetorDiferenca(VetorIn : Array of Double;Var VetorOut : Array of Double) : Boolean;
  function GetIPList: Tstrings; // Somente placas ativas
  procedure getCPUticks(var count: Int64); // Le o valor do contador de Clock do processador
  Function PeriodoClockCPU : double; // devolve em segundos

implementation

USES
  StdCtrls, WinSock;

Function PeriodoClockCPU : double; // devolve em segundos
var t1,t2 : cardinal;         //system clock ticks
    cput1,cput2 : Int64;      //CPU clock ticks
begin
 t1 := getTickCount;          //get milliseconds clock
 while getTickCount = t1 do;  //sync with start of 1 millisec interval
 getCPUticks(cput1);          //get CPU clock count
 t1 := gettickcount;
 repeat
  getCPUticks(cput2);         //get CPU clock count
  t2 := gettickcount;
 until t2-t1 >= 500;
// Result := ((t2-t1-1)*1e3) / (cput2-cput1);
 Result := (t2-t1-1) / ((cput2-cput1)*1e3);
end;

procedure getCPUticks(var count: Int64);
//store 64 bits CPU clock in variable count
begin
 asm
  mov ECX,count;
  RDTSC;          //lower 32 bits --> EAX, upper 32 bits ---> EDX
                  //RDTSC = DB $0F,$31
  mov [ECX],EAX;
  add ECX,4;
  mov [ECX],EDX;
 end;
end;

function GetIPList: Tstrings; // Somente placas ativas
type
  TaPInAddr = array [0 .. 255] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array [0 .. 63] of ansiChar;
  I: Integer;
  GInitData: TWSAData;
  DebugS : string;
begin
  wsastartup($101, GInitData);
  Result := TstringList.Create;
  Result.Clear;
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(Buffer);
  if phe = nil then
    Exit;
  pptr := PaPInAddr(phe^.h_addr_list);
  I := 0;
  while pptr^[I] <> nil do
  begin
    DebugS :=iNet_ntoa(pptr^[I]^);
    Result.Add(iNet_ntoa(pptr^[I]^));
    Inc(I);
  end;
  WSACleanup;
end;

Function DesvioPadrao(vet : array of double):double;
var
  i: integer;
  amedia,auxd:double;
begin
  Result:=0;
  amedia := Media(vet);
  for I := Low(vet) to High(vet) do
    Result := Result + Sqr(vet[i]-amedia);
  Result := Sqrt(Result / (High(vet)-Low(vet))); // DP=sqrt(SOMAT{Xi-media}/N-1)
end;
Function Media(vet : array of double):double;overload;
var cont:integer;
begin
  Result:=0;
  for cont := Low(vet) to High(vet) do
    Result:=Result+vet[cont];
  Result := Result / (1+High(vet)-Low(vet));
end;
Function Media(vet : array of single):single;overload;
var cont:integer;
begin
  Result:=0;
  for cont := Low(vet) to High(vet) do
    Result:=Result+vet[cont];
  Result := Result / (1+High(vet)-Low(vet));
end;
Function Media(vet : array of integer):single;overload;
var cont:integer;
begin
  Result:=0;
  for cont := Low(vet) to High(vet) do
    Result:=Result+vet[cont];
  Result := Result / (1+High(vet)-Low(vet));
end;

Function VetorDiferenca(VetorIn : Array of Double;Var VetorOut : Array of Double) : Boolean;
Var
  I : integer;
begin
  Result := False;
  if ( high(VetorIn) - Low(VetorIn) -high(VetorOut) + Low(VetorOut) ) <> 1 then
    Exit;
  for I := 0 to High(VetorOut) do
    VetorOut[i] := VetorIn[i] - VetorIn[Succ(i)];
  Result := True; //
end;

function CaptureScreenRect(aRect: TRect; aHandle: THandle): TBitmap;
var
  screenDC: HDC;
begin
  result:= TBitmap.Create;
  result.Width := aRect.Right - aRect.Left;
  result.Height:= aRect.Bottom - aRect.Top;
  screenDC:= getDC(aHandle);
  try
    BitBlt(result.Canvas.Handle, 0, 0, Result.Width, result.Height, screenDC, 0, 0, SRCCOPY);
  finally
    ReleaseDC(result.Canvas.Handle, screenDC);
  end;
end;


function  CalculaRMS(VetorD: array of double; qtdptos: integer): double;
var
  i: integer;
  resultado: double;
begin
  resultado:= 0;
  for i:= 0 to pred(qtdptos-1) do
    resultado:= resultado+sqr(VetorD[i]);
  resultado:= (resultado / qtdptos);
  resultado:= sqrt(resultado);
  result:= resultado;
end;

(*function ValidaCNPJ(sCNPJ: string; MostraMsg: boolean = true): boolean;
const
  String1 = '543298765432';
  String2 = '654329876543';
var
  i,j,Digito: byte;
  Controle: string[2];
  AuxCNPJ,StringX: string;
  Soma: smallint;
  n: integer;
begin
 if sCNPJ = '' then
  begin
    Result := false;
    exit;
  end;
  if sCNPJ = '00000000000000' then
  begin
    result := False;
    Exit;
  end;
  AuxCNPJ := sCNPJ;
  for n := 1 to length(AuxCNPJ) do
  begin
    if (AuxCNPJ[n] >= '0') and (AuxCNPJ[n] <= '9') then
      sCNPJ := sCNPJ + AuxCNPJ[n];
  end;
  sCNPJ := Copy( '00000000000000'+Trim(sCNPJ),(Length(Trim(sCNPJ))+14)-13,14 );
  Controle := '   ';
  Digito := 0;
  StringX := String1;
  for i := 1 to 2 do
  begin
    Soma := 0;
    if i = 2 then StringX := String2;
      for j := 1 to 12 do
        Soma := Soma + ( StrToIntDef(sCNPJ[j],0) * StrToIntDef(StringX[j],0) );
    if i = 2 then
      Soma := Soma + (2 * Digito);
    Digito := (Soma * 10) Mod 11;
    if Digito = 10 then
      Digito := 0;
    Controle[i] := IntToStr( Digito )[1];
  end;
  Result := Controle = Copy( sCNPJ,13,2 );
end;
  *)
function ValidaCPF(num: string): boolean;
var
  n, n1,n2,n3,n4,n5,n6,n7,n8,n9: integer;
  d1,d2: integer;
  auxcpf, digitado, calculado: string;
begin
  auxcpf := num;
  num := '';
  //para s? pegar numeros
  for n := 1 to length(auxcpf) do
  begin
    if (auxcpf[n] >= '0') and (auxcpf[n] <= '9') then
      num := num + auxcpf[n];
  end;
  //ver se nao colocou 00000000000
  if num = '00000000000' then
  begin
    Result := false;
    exit;
  end;
  //ver se tem 11 caractres
  if (length(num) <> 11) then
  begin
    Result := false;
    exit;
  end;
  n1:=StrToInt(num[1]);
  n2:=StrToInt(num[2]);
  n3:=StrToInt(num[3]);
  n4:=StrToInt(num[4]);
  n5:=StrToInt(num[5]);
  n6:=StrToInt(num[6]);
  n7:=StrToInt(num[7]);
  n8:=StrToInt(num[8]);
  n9:=StrToInt(num[9]);
  d1:=n9*2+n8*3+n7*4+n6*5+n5*6+n4*7+n3*8+n2*9+n1*10;
  d1:=11-(d1 mod 11);
  if d1>=10 then
    d1:=0;
  d2:=d1*2+n9*3+n8*4+n7*5+n6*6+n5*7+n4*8+n3*9+n2*10+n1*11;
  d2:=11-(d2 mod 11);
  if d2>=10 then
    d2:=0;
  calculado:=inttostr(d1)+inttostr(d2);
  digitado:=num[10]+num[11];
  if calculado=digitado then
    ValidaCPF:=true
  else
    ValidaCPF:=false;
end;

procedure AcertaDivisaoComDizima(Valor: string; Qtd: Smallint; var Retorno1,Retorno2: double);
var
  V1: string;
  vf, diferenca, valortransf: double;
begin
  //se qtd = 0 provavelmente ? s? um servi?o,
  //entao a qtd sendo 1 naum deve fazer diferenca para esta conta-> guiarone
  if Qtd = 0 then
    Qtd:= 1;
  //isso ? escroto mas ? por causa do strtofloat que sempre deixa um lixo....
  //acerta o valor...
  try
    valortransf:= StrToFloatDef(valor,0);
    V1:= formatfloat('0.00', valortransf);
    valortransf:= StrToFloatDef(v1,0);
    //descobre a dizima...
    vf := StrToFloatDef(valor,0) / qtd;
    V1:= formatfloat('0.00', vf);
    //agora o valor esta arredondado para o que iria valer na conta...
    vf:= StrToFloatDef(V1,0) * qtd;
    V1:= formatfloat('0.00', vf);
    //se arrendondou certo, o valor dever ser o mesmo
    if V1 = Valor then
    begin
      Retorno1:= strtofloatdef(valor,0) / qtd;
      Retorno2:= StrToFloatDef(valor,0) / qtd;
    end
    else//se nao, vou ter q fazer a m?gica
    begin
      vf:= strtofloat(V1);
      diferenca:= vf - valortransf;
      if qtd = 0 then //solucao minha rafael
        Retorno1:= vf //
      else //
        Retorno1:= vf / qtd;
      Retorno2:= Retorno1 - diferenca;
    end;
  except
    Retorno1:= 0;
    Retorno2:= 0;
  end;
end;

function ValorRealporEstenso(valor: Single): String;
var
  milhar, Centena, Centavo, Numerotexto: string;

const
  Unidades : array[1..9] of string = ('Um','Dois','Tres','Quatro','Cinco','Seis','Sete','Oito','Nove');
  Dez: array[1..9] of string = ('Onze', 'Doze', 'Treze', 'Quatorze', 'Quinze', 'Dezesseis', 'Dezessete', 'Dezoito', 'Dezenove');
  Dezenas: array[1..9] of string = ('Dez', 'Vinte', 'Trinta', 'Quarenta', 'Cinquenta', 'Sessenta', 'Setenta', 'Oitenta', 'Noventa');
  Centenas: array[1..9] of string = ('Cento', 'Duzentos', 'Trezentos', 'Quatrocentos', 'Quinhentos', 'Seiscentos', 'Setecentos', 'Oitocentos', 'Novecentos');

  function ifs(Expressao: Boolean; CasoVerdadeiro, CasoFalso: String): String;
  begin
    if Expressao
    then Result:=CasoVerdadeiro
    else Result:=CasoFalso;
  end;

  function RetornaValorParcial(trio: string): string;
  var
    Unidade, Dezena, cento: string;
  begin
    Unidade:= '';
    Dezena:= '';
    cento:= '';
    if (trio[2] = '1') and (trio[3] <> '0') then
    begin
      Unidade:= Dez[strtoint(trio[3])];
      Dezena := '';
    end
    else
    begin
      if trio[2] <> '0' then
        Dezena:= Dezenas[strtoint(Trio[2])];
      if trio[3] <> '0' then
        Unidade:= Unidades[strtoint(trio[3])];
    end;

    if ((trio[1] = '1') and (Unidade = '') and (Dezena = '')) then
      cento := 'Cem'
    else
      if trio[1] <> '0' then
        cento := Centenas[strtoint(trio[1])]
      else
        cento:= '';
     Result:= Cento + ifs((Cento <> '') and ((Dezena <> '') or (Unidade <>'')), ' e ', '')
     + Dezena + ifs((Dezena <> '') and (Unidade <> ''),' e ', '') + Unidade;
  end;

begin
  if (valor = 0) then
  begin
    result := 'Zero';
    exit;
  end;

  Numerotexto := FormatFloat('000000.00',valor);
  milhar:= RetornaValorParcial(Copy(Numerotexto,1,3));
  Centena:= RetornaValorParcial(Copy(Numerotexto,4,3));
  Centavo:= RetornaValorParcial('0'+Copy(Numerotexto,8,2));
  Result := milhar;
  if milhar <> '' then
    if Copy(Numerotexto,4,3) = '000'then
      Result := Result + ' Mil Reais'
    else
      Result := Result + ' Mil, ';
  if (((copy(Numerotexto,4,2) = '00') and (Milhar<>'') and (copy(Numerotexto,6,1)<>'0')) or (centavo='')) and (Centena <> '') then
    Result:=Result+' e ';

  //meu pra tirar o e da frente quando nao tiver milhar
  if milhar = '' then
   Result := copy(Result,4,length(Result) - 3);
  //
  if (Milhar+Centena <>'') then
    Result:=Result+Centena;
  if (Milhar='') and (copy(Numerotexto,4,3)='001') then
    Result:=Result+' Real'
  else
    if (copy(Numerotexto,4,3)<>'000') then
      Result:=Result+' Reais';
  if Centavo='' then
  begin
    Result:=Result+'.';
    Exit;
  end
  else
  begin
    if Milhar+Centena='' then
      Result:=Centavo
    else
     Result:=Result+', e '+Centavo;

    if (copy(Numerotexto,8,2)='01') and (Centavo<>'') then
      Result:=Result+' Centavo.'
    else
      Result:=Result+' Centavos.';
  end;
end;

function FormataCPF_CNPJ(S: string): string;
const
  TamCNPJ = 14;
  TamCPF = 11;
var
  i: integer;
  NovaString: string;
begin
  NovaString:= '';
  if Length(S) = TamCNPJ then
  begin
    for i:= 1 to Length(S) do
    begin
      NovaString:= NovaString+S[i];
      if (i = 2) or (i = 5)then
        NovaString:= NovaString+'.';
      if (i = 8)then
        NovaString:= NovaString+'/';
      if (i = 12)then
        NovaString:= NovaString+'-';
    end;
  end
  else
  begin
    for i:= 1 to Length(S) do
    begin
      NovaString:= NovaString+S[i];
      if (i = 3) or (i = 6)then
        NovaString:= NovaString+'.';
      if (i = 9)then
        NovaString:= NovaString+'-';
    end;
  end;
  Result:=NovaString;
end;

function DescobreVersaoWindows: byte;
var
  OSVersionInfo : TOSVersionInfo;
begin
  OsVersionInfo.dwOSVersionInfoSize := SizeOf(TOsVersionInfo);
  GetVersionEx(OsVersionInfo);
  result:= OsVersionInfo.dwPlatformId;
{  with OsVersionInfo do begin
    Label4.Caption := IntToStr(dwMajorVersion);
    Label5.Caption := IntToStr(dwMinorVersion);
    Label6.Caption := IntToStr(LoWord(dwBuildNumber));
    case dwPlatformID of
      VER_PLATFORM_WIN32S : Label8.Caption := 'Win32s';
      VER_PLATFORM_WIN32_WINDOWS : Label8.Caption := 'Windows 95/98';
      VER_PLATFORM_WIN32_NT : Label8.Caption := 'Windows NT';
    end;
  end;}
end;

function Exibemsg(msg: string): integer;
var
  i: smallint;
begin
  with CreateMessageDialog(msg,mtConfirmation,[mbYes,mbYesToAll, mbNo]) do
  try
    Caption := 'Aten??o!';
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TButton then
      begin
        with TButton(Components[i]) do
        begin
          case ModalResult of
            mrYes      : Caption := 'Sim';
            mrYesToAll : Caption := 'Sim todos';
            mrNo       : Caption := 'N?o';
          end;
        end;
      end;
    result:= ShowModal;
  finally
    Free;
  end;
end;//function Exibemsg(msg: string): integer;

Function PrinterOnLine : Boolean;
Const
  PrnStInt : Byte = $17;
  StRq : Byte = $02;
  PrnNum : Word = 0; { 0 para LPT1, 1 para LPT2, etc. }
Var
  nResult : byte;
Begin (* PrinterOnLine*)
  Asm
  mov ah,StRq;
  mov dx,PrnNum;
  Int $17;
  mov nResult,ah;
end;
  PrinterOnLine := (nResult and $80) = $80;
End;

function GetDadosEMF(nomeArq: string): THeaderEMF;
var
  Arq: File Of THeaderEMF;
  Dados: THeaderEMF;
begin
  AssignFile(Arq, nomeArq);
  {$I-}Reset(Arq);{$I+}
  read(Arq, Dados);
  closefile(Arq);
  result:= Dados;
end;

function ResumeTamanhoEMDisco(V: int64): string;
begin
  if V < 1024 then
    result:= inttostr(V)+' bytes'
  else
    if V < 1024*1024 then
      result:= formatfloat('0.00 Kbytes',V / 1024)
    else
      if V < 1024*1024*1024 then
        result:= formatfloat('0.00 Mbytes',V/(1024*1024))
      else
        result:= formatfloat('0.00 Gbytes',V/(1024*1024*1024));
end;

function EsperaMS(tempo: word): boolean;
var
  antes, agora: dword;
begin
  if tempo = 0 then
  begin
    result:= false;
    exit;
  end;
  antes:= GetTickCount;
  agora:= antes;
  //aguarda um tempo para reset...
  while (antes+tempo) > agora do
    agora:= GetTickCount;
end;

function getTamdir(Caminho: string): double;
var
  Lista: TStringList;
//  F: file of byte;
  F: TFileStream;
  Tam: int64;
  i: smallint;
  Cam: string;
begin
  Tam:= 0;
  Lista:= TStringList.Create;
  Lista.Assign(Dir(Caminho+'\*.*', faArchive));
  if Lista.count > 0 then
  begin
    for i:= 0 to pred(Lista.count) do
    begin
      if (Lista[i] <> '..') and (Lista[i] <> '.') then
      begin
        {$I-}
        Cam:= Caminho+'\'+Lista[i];
//        AssignFile(F, Cam);
        F:= TFileStream.Create(Cam, fmOpenRead);
//        Reset(F);
        {$I+}
//        Tam := Tam + FileSize(F);
        Tam := Tam + F.Size;
//        closefile(F);
        FreeAndNil(F);
      end;
    end;
  end;
  Lista.Free;
  result:= tam;
end;

function ApagaArquivo(Caminho: string): boolean;
begin
  result:= deletefile(Caminho);
end;

function CalculaIdade(Data2, Data1: String): String;
{********************************************************}
{*** Calula a idade de duas datas no formato AAAAMMDD ***}
{********************************************************}
var
  Idade : String;
  Anos, Meses, Dias : Integer;
begin
  Result := 'Idade n?o Dispon?vel';

  {*** Verifica se as datas t?m 8 d?gitos (AAAAMMDD) ***}
  If (Length(Data1) <> 8) or (Length(Data2) <> 8) then
    Exit;

  try
    {*** Calcula diferencas de anos, meses e dias ***}
    Anos := StrToInt(Copy(Data2, 1, 4)) - StrToInt(Copy(Data1, 1, 4));
    Meses:= StrToInt(Copy(Data2, 5, 2)) - StrToInt(Copy(Data1, 5, 2));
    Dias := StrToInt(Copy(Data2, 7, 2)) - StrToInt(Copy(Data1, 7, 2));
  except
    result:= '00/00/0000';
    Exit;
  end;

  {*** Ajusta fracao de ano ***}
  if (Meses < 0) then
  begin
    Dec(Anos);
    Inc(Meses, 12);
  end;

  {*** Ajusta fracao de mes ***}
  if (Dias < 0) then
  begin
    Dec(Meses);
    Inc(Dias, 31); {*** Inc. de 31 porque o numero de dias n?o importa ***}
    if (Meses < 0) then
    begin
      Dec(Anos);
      Inc(Meses, 12);
    end;
  end;

  {*** Monta o resultado => "xx anos e yy meses" ***}
  Idade:= '0 ano';
  if (Anos > 0) then
  begin
    Idade:= IntToStr(Anos);
    if (Anos > 1) then
      Idade:= Idade + ' anos'
    else
      Idade:= Idade + ' ano';
  end;

  if (Meses > 0) then
  begin
    if (Anos > 0) then
      Idade:= Idade + ' e ';
    Idade:= Idade  + IntToStr(Meses);
    if (Meses > 1) then
      Idade:= Idade  + ' meses'
    else
      Idade:= Idade  + ' m?s';
  end;

  Result:= Idade;
end;

function IdadeExtenso;
{********************************************************}
{*** Calula a idade de duas datas no formato AAAAMMDD ***}
{********************************************************}
var
  Idade : String;
  Anos, Meses, Dias : Integer;
begin
  Result := 'Idade n?o Dispon?vel';

  {*** Verifica se as datas t?m 8 d?gitos (AAAAMMDD) ***}
  If (Length(Data1) <> 8) or (Length(Data2) <> 8) then
    Exit;

  try
    {*** Calcula diferencas de anos, meses e dias ***}
    Anos := StrToInt(Copy(Data2, 1, 4)) - StrToInt(Copy(Data1, 1, 4));
    Meses:= StrToInt(Copy(Data2, 5, 2)) - StrToInt(Copy(Data1, 5, 2));
    Dias := StrToInt(Copy(Data2, 7, 2)) - StrToInt(Copy(Data1, 7, 2));
  except
    Exit;
  end;

  {*** Ajusta fracao de ano ***}
  if (Meses < 0) then
  begin
    Dec(Anos);
    Inc(Meses, 12);
  end;

  {*** Ajusta fracao de mes ***}
  if (Dias < 0) then
  begin
    Dec(Meses);
//    Inc(Dias, 31); {*** Inc. de 31 porque o numero de dias n?o importa ***}
    if (Meses < 0) then
    begin
      Dec(Anos);
      Inc(Meses, 12);
    end;
  end;

  {*** Monta o resultado => "xx anos e yy meses" ***}
  Idade:= '';
  if (Anos > 0) then
  begin
    Idade:= IntToStr(Anos);
    if (Anos > 1) then
      Idade:= Idade + ' a'
    else
      Idade:= Idade + ' a';
  end;

  if (Meses >= 0) then
  begin
    if (Anos > 0) then
      Idade:= Idade + ' e ';
    if (Meses > 1) then
      Idade:= Idade + IntToStr(Meses) + ' m'
    else
      Idade:= Idade + IntToStr(Meses) + ' m';
  end;

  Result:= Idade;
end; {### function IdadeExtenso ###}

function  CalculaIdade2(Data2, Data1: String):integer;
{********************************************************}
{*** Calula a idade de duas datas no formato AAAAMMDD ***}
{********************************************************}
var
  Idade : integer;
  Anos, Meses, Dias : Integer;
begin
  Result := 0;

  {*** Verifica se as datas t?m 8 d?gitos (AAAAMMDD) ***}
  If (Length(Data1) <> 8) or (Length(Data2) <> 8) then
    Exit;

  try
    {*** Calcula diferencas de anos, meses e dias ***}
    Anos := StrToInt(Copy(Data2, 1, 4)) - StrToInt(Copy(Data1, 1, 4));
    Meses:= StrToInt(Copy(Data2, 5, 2)) - StrToInt(Copy(Data1, 5, 2));
    Dias := StrToInt(Copy(Data2, 7, 2)) - StrToInt(Copy(Data1, 7, 2));
  except
    result:= 0;
    Exit;
  end;

  {*** Ajusta fracao de ano ***}
  if (Meses < 0) then
  begin
    Dec(Anos);
    Inc(Meses, 12);
  end;

  {*** Ajusta fracao de mes ***}
  if (Dias < 0) then
  begin
    Dec(Meses);
    Inc(Dias, 31); {*** Inc. de 31 porque o numero de dias n?o importa ***}
    if (Meses < 0) then
    begin
      Dec(Anos);
      Inc(Meses, 12);
    end;
  end;
  Idade:= 0;
  if (Anos > 0) then
    Idade:= Anos;
  Result:= Idade;
end;

function RetornaEspacoLivre(S: string): int64;
var
  PStrAux: array[0..255] of char;
  FreeAvaiable, TotalSpace, TotalFree: int64;
begin
  strpcopy(PStrAux, S);
  GetDiskFreeSpaceEx(PStrAux,FreeAvaiable, TotalSpace, @TotalFree);
  result:= TotalFree;
end;

function  apagaarquivos(mascara:string):integer;
var
  sr : TSearchRec;
  l :TStringList;
  i,total:integer;
begin
  total :=0;
  l:= TStringList.Create;
  if FindFirst(mascara,faanyfile,sr) = 0 then
  begin
    repeat
      l.Add(sr.Name)
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  for i := 0 to pred(l.Count) do
    if deletefile(ExtractFilePath(mascara)+l[i]) then
      inc(total);
  l.Free;
  result := total;
end;

function GetCodUnidade(LetraUnidade: char): byte;
begin
  result:= ord(UpCase(LetraUnidade)) - ord('A') + 1;
end;

function FormataEspacoLivre(BKMGT: byte; unidade: string): string;
var
  FreeAvailable, totalspace, Disponivel: int64;
  Dest: array[0..200] of char;
  U: byte;
  aux: string;
begin
  StrPCopy(Dest, unidade);
  if GetDiskFreeSpaceEx(Dest, FreeAvailable, totalspace, @Disponivel) then
  begin
    case BKMGT of
      0: result:= formatfloat('0,0 Bytes', Disponivel);//bytes
      1: result:= formatfloat('0,0 KB', Disponivel/1024);//kbytes
      2: result:= formatfloat('0,0 MB', Disponivel/1024/1024);//mbytes
      3: result:= formatfloat('0,0 GB', Disponivel/1024/1024/1024);//gbytes
      4: result:= formatfloat('0,0 TB', Disponivel/1024/1024/1024/1024);//tbytes
      else
      begin
        BKMGT:= 0;
        while Disponivel > 1024 do
        begin
          Disponivel:= round(Disponivel / 1024);
          inc(BKMGT);
        end;//while Disponivel > 1024 do
        case BKMGT of
          0: aux:= ' Bytes';
          1: aux:= ' KB';
          2: aux:= ' MB';
          3: aux:= ' GB';
          4: aux:= ' TB';
        end;//case BKMGT of
        result:= formatfloat('0,0', Disponivel)+aux;//tbytes
      end;//else
    end;//case BKMGT of
  end//if GetDiskFreeSpaceEx(Dest, FreeAvailable, totalspace, @Disponivel) then
  else
    result:= 'Unidade inv?lidada.';
end;

function getEspacoLivre(Destino: string): int64;
var
  FreeAvailable, totalspace, Disponivel: int64;
  Dest: array[0..200] of char;
 U: byte;
begin
    StrPCopy(Dest,Destino);
    if not GetDiskFreeSpaceEx(Dest, FreeAvailable, totalspace, @Disponivel) then
    begin
      U:= ord(UpCase(Destino[1]))-ord('A') + 1;
      try
        result:= DiskFree(U);
      except
        result:= 0;
      end;
    end
    else
      result:= Disponivel;
end;//function getEspacoLivre(Destino: string): int64;

function getFileSize(Arquivo: string): integer;
var
  s:TSearchRec;
begin
  TRY
    if FindFirst(Arquivo,faAnyFile,s) = 0 then
      result:= s.Size
    else
      result:= -1;
    FindClose(s);
  EXCEPT
    SHOWMESSAGE('ERRO AO TENTAR LOCALIZAR ARQUIVO '+Arquivo);
  END;
end;

function RetiraEspacos( S: String): String;
var
  i: integer;
  R: string;
begin
  R:= '';
  if Length(S) > 1 then
  begin
    for i:= 1 to pred(Length(S)) do
      if (S[i] <> ' ') or (S[i+1] <> ' ') then
        R:= R+S[i];
    i:= {pred(}Length(S){)};
    if S[Length(S)] <> ' ' then
      R:= R+S[i];
    result:= R;
  end
  else
  begin
    if s <> ' ' then
      result:= S
    else
      result:= '';
  end;
end;

Procedure Diret;
var
//  Lista : TStringList;
  Achou : Integer;
  SearchRec : TSearchRec;
begin
//  Lista:= TStringList.Create;

  Achou:= FindFirst(Mask, Attr, SearchRec);
  while (Achou = 0) do
  begin
    Lista.Add(SearchRec.Name);
    Achou:= FindNext(SearchRec);
  end;
  FindClose(SearchRec);

//  Result:= Lista;
end; {### function Dir ###}

function CopiaArquivo(Origem, Destino: string): boolean;
const
  LimiteDeEspaco = 4096;
var
  Buf: array[1..2048] of Char;
  Lidos, Tamanho: int64;
  FF, TF: TFileStream;
begin
  if not fileexists(Origem) then//se naum existir a origem sai...
  begin
    result:= false;
    exit;
  end;
  FF:= TFileStream.Create(Origem, fmOpenRead);
  TF:= TFileStream.Create(Destino, fmCreate);
  Tamanho:= FF.Size;
  Lidos:= 0;
  Application.ProcessMessages;
  repeat
    if (Tamanho - Lidos) > 2048 then
    begin
      FF.Read(Buf, sizeof(Buf));
      Tf.Write(Buf, sizeof(Buf));
      Lidos:= Lidos + sizeof(Buf);
    end
    else
    begin
      FF.Read(Buf, Tamanho - Lidos);
      Tf.Write(Buf, Tamanho - Lidos);
      Lidos:= Lidos + (Tamanho - Lidos);
    end;
  until Lidos >= Tamanho;
  FF.Free;
  Tf.Free;
  result:= true;
end;

function CopiaArquivo2(Origem, Destino: string): boolean;
const
  LimiteDeEspaco = 4096;
var
  FOrigem, FDestino: file;
  Lidos, Gravados,tamarq: integer;
  livre: int64;
  ax:string;
  pori, pdest: array[0..200] of char;
  b: boolean;
begin
  if not fileexists(Origem) then//se naum existir a origem sai...
  begin
    result:= true;
    exit;
  end;
  ax:= copy(Destino, 1, 2);
  livre:= RetornaEspacoLivre( ax );
  tamarq := getFileSize(Origem);
  if tamarq < 0 then
    ShowMessage('O arquivo: '+Origem+' n?o p?de ser aberto');
  if livre < tamarq then
  begin
    result:= false;
    exit;
  end;
  StrPCopy(pori, Origem);
  StrPCopy(pdest, Destino);
  b:= false;
  if fileexists(Destino) then
    deletefile(Destino);
  result:= CopyFile(pori, pdest, false);
  FileSetAttr(pdest, 0);
{  assignfile(FOrigem,Origem);
  reset(FOrigem, 1);
  assignfile(FDestino,Destino);
  rewrite(FDestino, 1);
  repeat
    BlockRead(FOrigem, Buf, SizeOf(Buf), Lidos);
    BlockWrite(FDestino, Buf, Lidos, Gravados);
  until (Lidos = 0) or (Gravados <> Lidos);
  closefile(FOrigem);
  closefile(FDestino);
  result:= true;}
end;

function CopiaArquivoNova(Origem, Destino: string): integer;
const
  LimiteDeEspaco = 4096;
var
  FOrigem, FDestino: file;
  Lidos, Gravados,tamarq: integer;
  livre: int64;
  ax:string;
  pori, pdest: array[0..200] of char;
  b: boolean;
begin
  if not fileexists(Origem) then//se naum existir a origem sai...
  begin
    result:= -1;
    exit;
  end;
  ax:= copy(Destino, 1, 2);
  livre:= RetornaEspacoLivre( ax );
  tamarq := getFileSize(Origem);
  if tamarq < 0 then
    ShowMessage('O arquivo: '+Origem+' n?o p?de ser aberto');
  if livre < tamarq then
  begin
    result:= 0;
    exit;
  end;
  StrPCopy(pori, Origem);
  StrPCopy(pdest, Destino);
  b:= false;
  if fileexists(Destino) then
    deletefile(Destino);
  if CopyFile(pori, pdest, false) then
    result:= tamarq
  else
    result:= 0;
  FileSetAttr(pdest, 0);
end;

procedure ProcuraPastas(Caminho,Nome: string; var aL:TStringList);
var
  F:TSearchRec;
  achou: integer;
begin
  achou:= findfirst(addbackslash(Caminho)+Nome, faDirectory, F);
  while achou = 0 do
  begin
    if (F.Name <>'.') and (F.Name <>'..')then
      if (F.Attr = faDirectory) or (F.Attr = 17) then
        aL.add(F.Name);
    achou:= findnext(F);
  end;
  findclose(F);
end;

procedure ProcuraArquivos(Caminho,Nome: string; var aL:TStringList; crono: boolean = false);
type
  TListaEsperta = packed record
    Tempo: integer;
    Nome: string;
  end;
var
  F:TSearchRec;
  i, j, cont, achou: integer;
  ListaEsperta: array of TListaEsperta;
  ListaT: TStringList;
begin
  achou:= findfirst(addbackslash(Caminho)+Nome, faAnyFile, F);
  while achou = 0 do
  begin
    aL.Add(addbackslash(Caminho)+F.Name);
    achou:= findnext(F);
  end;
  findclose(F);
  if crono then
  begin
    setlength(ListaEsperta, aL.count);
    ListaT:= TStringList.Create;
    cont:= 0;
    achou:= findfirst(addbackslash(Caminho)+Nome, faAnyFile, F);
    while achou = 0 do
    begin
      ListaT.Add(IntToStr(F.Time));
      ListaEsperta[cont].Tempo:= F.Time;
      ListaEsperta[cont].Nome:= addbackslash(Caminho)+F.Name;
      inc(cont);
      achou:= findnext(F);
    end;
    aL.clear;
    ListaT.Sort;
    for i:= 0 to ListaT.Count - 1 do
    begin
      achou:= 0;
      j:= 0;
      while (achou = 0) and (j < ListaT.Count) do
      begin
        if ListaT[i] = inttostr(ListaEsperta[j].Tempo) then
        begin
          aL.add(ListaEsperta[j].Nome);
          ListaEsperta[j].Tempo:= -1;
          achou:= 1;
        end
        else
          inc(j);
      end;                                               

    end;

    findclose(F);
  end;

end;

function textotofloat(sa:string):double;
var
  car:char;
  pos:integer;
begin
  if length(sa) <1 then
  begin
    result := 0;
    exit;
  end;
  car:= FormatSettings.DecimalSeparator;
  pos:=1;
  if car = '.' then
    while pos < Length(sa) do
    begin
      if sa[pos] = ',' then
        sa[pos]:= '.';
      inc(pos);
    end;
  if car = ',' then
    while pos < Length(sa) do
    begin
      if sa[pos] = '.' then
        sa[pos]:= ',';
      inc(pos);
    end;
  result:= StrToFloat(sa);
end;

function  RetiraCaracterInvalido(sa: string): string;
var
  i: integer;
begin
  result:= '';
  for i:= 1 to length(sa) do
  begin
    if ((sa[i]>='0') and (sa[i]<='9')) or
       ((sa[i]>='A') and (sa[i]<='Z')) or
       ((sa[i]>='a') and (sa[i]<='z')){ or
        (sa[i] =' ') }then
      result:= result+sa[i]
  end;
end;

function testastringNumInt(sa: string): boolean;
var
  i: integer;
begin
  result:= true;
  for i:= 0 to pred(length(sa)) do
  begin
    if ((sa[succ(i)] >='0') and (sa[succ(i)] <='9')) then
      result:= true
    else
    begin
      result:= false;
      Break;
    end;
  end;
end;

function testastringnumerica(sa: string): boolean;
var
  i: integer;
begin
  result:= true;
  for i:= 0 to pred(length(sa)) do
  begin
    if ((sa[succ(i)] >='0') and (sa[succ(i)] <='9')) or
       ((sa[succ(i)] ='.') or (sa[succ(i)] =',')or (sa[succ(i)] ='-')) then
      result:= true
    else
    begin
      result:= false;
      Break;
    end;
  end;
end;

function AddBackSlash;
var
 Temp: string;
begin
  Temp := S;
  if S[Length(Temp)] <> '\' then
    Temp := Temp + '\';
  AddBackSlash := Temp;
end; {### function AddBackSlash ###}

function CompletaComEspacos( S: String; Tam: Integer ): String;
var
  i : Integer;
begin
  for i:= Succ( Length( S ) ) to Tam do
    S:= S + ' ';
  Result:= S;
end; {### function CompletaComEspacos ###}

function RetiraEspacosDoFinal( S: String): String;
var
  Tam: integer;
begin
  Tam:= Length(S);
  while S[Tam] = ' ' do
  begin
    delete(S, Tam, 1);
    dec(Tam);
  end;
  result:= S;
end;

function DataValida;
var
  A, M, D : SmallInt;
begin
  Result:= false;

  A:= StrToIntDef( Copy( AAAAMMDD, 1, 4 ), -1 );
  M:= StrToIntDef( Copy( AAAAMMDD, 5, 2 ), -1 );
  D:= StrToIntDef( Copy( AAAAMMDD, 7, 2 ), -1 );

  if ( A > 0 ) then  // Ano valido esta entre 0000 e 9999
  begin
    case M of // Mes valido esta entre 1 e 12
      2 : // fevereiro
      begin
        if ( A mod 4 = 0 ) then // e bissexto
          Result:= ( D >= 1 ) and ( D <= 29 )
        else  // nao e bissexto
          Result:= ( D >= 1 ) and ( D <= 28 );
      end;
      1, 3, 5, 7, 8, 10, 12 : Result:= ( D >= 1 ) and ( D <= 31 );
      4, 6, 9, 11           : Result:= ( D >= 1 ) and ( D <= 30 );
    end;
  end;
end; {### function DataValida ###}

function DesformataData(DD_MM_AAAA: String): String;
var
  SAux : String;
  A, M, D : SmallInt;
begin
  DD_MM_AAAA:= Trim( DD_MM_AAAA );
  Result:= '#0';
  if (Length(DD_MM_AAAA) = 10) then
  begin
    try
      A:= StrToInt(Copy(DD_MM_AAAA, 7, 4));
      M:= StrToInt(Copy(DD_MM_AAAA, 4, 2));
      D:= StrToInt(Copy(DD_MM_AAAA, 1, 2));
      SAux:= StrZero(A, 4) + StrZero(M, 2) + StrZero(D, 2);
    except
      Exit; // erro na formatacao
    end;
    Result:= SAux;
  end;
end; {### function DesformataData ###}

function Dir;
var
  Lista : TStringList;
  Achou : Integer;
  SearchRec : TSearchRec;
begin
  Lista:= TStringList.Create;

  Achou:= FindFirst(Mask, Attr, SearchRec);
  while (Achou = 0) do
  begin
    Lista.Add(SearchRec.Name);
    Achou:= FindNext(SearchRec);
  end;
  FindClose(SearchRec);

  Result:= Lista;
end; {### function Dir ###}

function FormataData2D(AAAAMMDD: String): String;
var
  SAux : String;
  A, M, D : SmallInt;
begin
  AAAAMMDD:= Trim( AAAAMMDD );
//  Result:= '#0';
  Result:= '';
  if (Length(AAAAMMDD) = 8) then
  begin
    try
      A:= StrToInt(Copy(AAAAMMDD, 3, 2));
      M:= StrToInt(Copy(AAAAMMDD, 5, 2));
      D:= StrToInt(Copy(AAAAMMDD, 7, 2));
      SAux:= StrZero(D, 2) + '/' + StrZero(M, 2) + '/' + StrZero(A, 2);
    except
      Exit; // erro na formatacao
    end;
    Result:= SAux;
  end;
end; {### function FormataData ###}

function FormataData;
var
  SAux : String;
  A, M, D : SmallInt;
begin
  AAAAMMDD:= Trim( AAAAMMDD );
//  Result:= '#0';
  Result:= '';
  if (Length(AAAAMMDD) = 8) then
  begin
    try
      A:= StrToInt(Copy(AAAAMMDD, 1, 4));
      M:= StrToInt(Copy(AAAAMMDD, 5, 2));
      D:= StrToInt(Copy(AAAAMMDD, 7, 2));
      SAux:= StrZero(D, 2) + '/' + StrZero(M, 2) + '/' + StrZero(A, 4);
    except
      Exit; // erro na formatacao
    end;
    Result:= SAux;
  end;
end; {### function FormataData ###}

function  TempoEmSegundos(hh_mm_ss: string): integer;
var
  h,m,s: integer;
begin
  h:= strtointdef(copy(hh_mm_ss,1,2),0);
  m:= strtointdef(copy(hh_mm_ss,4,2),0);
  s:= strtointdef(copy(hh_mm_ss,7,2),0);
  h:= h*3600; m:= m *60;
  result:= h+m+s;
end;

function  DesformataTempo(HH_MM_SS:string): integer;
var
  H, M, S: integer;
begin
  H:= strtoint(copy(HH_MM_SS, 1, 2));
  M:= strtoint(copy(HH_MM_SS, 4, 2));
  S:= strtoint(copy(HH_MM_SS, 7, 2));
  result:= H*3600 + M*60 + S;
end;

function FormataTempo(Segundos: Integer): String;
var
  H, M : SmallInt;
begin
  try
    H:= Segundos div 3600;  // horas
    Segundos:= Segundos - (H * 3600);
    M:= Segundos div 60;    // minutos
    Segundos:= Segundos - (M * 60);
    Result:= StrZero(H, 2) + ':' + StrZero(M, 2) + ':' + StrZero(Segundos, 2);
  except
    Result:= 'xx:xx:xx';
  end;
end; {### function FormataTempo ###}

function FormataTempo(Segundos: Double): String;
var
  H, M, S, ms : SmallInt;
  Sms:string;
begin
  try
    H:= Trunc(Segundos / 3600);  // horas
    Segundos:= Segundos - (H * 3600);
    M:= Trunc(Segundos / 60);    // minutos
    S:= Trunc(Segundos - (M * 60));
    Segundos:= Segundos - (M * 60);
    ms:= Trunc((Segundos - S)*1000);
    sms:= StrZero(ms, 3);
    if sms[3]='0' then
      sms:=copy(sms,1,2);
    if sms[2]='0' then
      sms:=copy(sms,1,1);
    Result:= StrZero(H, 2) + ':' + StrZero(M, 2) + ':' + StrZero(S, 2)+',' + Sms;
  except
    Result:= 'xx:xx:xx:xxx';
  end;
end;//function FormataTempo(Segundos: Integer, ms: boolean): String;override
function StrZero;
var
  Count: byte;
  AuxStr: string;
begin
  Str(Num:Tam, AuxStr);
  for Count:= 1 to Length(AuxStr) do
    if AuxStr[Count] = #32 then
      AuxStr[Count]:= '0';
  Result:= AuxStr;
end; {### function StrZero ###}

Procedure pegaArq(caminho:string; var lis:TStringList);
var
  sr:TSearchRec;
  achou:integer;
begin
  achou := FindFirst(caminho,faAnyfile,sr);
  while achou = 0 do
  begin
    if (sr.Name <> '..') and (sr.Name <> '.') then
      lis.Add(sr.Name);
    achou := FindNext(sr);
  end;
  FindClose(sr);
  lis.Sort;
end;

procedure CopiaArquivoComGauge(Source, Dest: String; var G: TGauge);
const
  TamBufLocal = 4*2048;
var
  Buf: array[1..TamBufLocal] of Char;
  FromF, ToF: TFileStream;
  Lidos, Tamanho: int64;
begin
  FromF:= TFileStream.Create(Source, fmOpenRead);
  try
  ToF:= TFileStream.Create(Dest, fmCreate);
  except
    ShowMessage('Erro ao criar arquivo.');
    FreeAndNil(FromF);
    exit;
  end;
  Tamanho:= FromF.Size;
  Lidos:= 0;
  G.MaxValue:=Tamanho;
  repeat
    if (Tamanho - Lidos) > TamBufLocal then
    begin
      FromF.Read(Buf, sizeof(Buf));
      Tof.Write(Buf, sizeof(Buf));
      Lidos:= Lidos + sizeof(Buf);
    end
    else
    begin
      FromF.Read(Buf, Tamanho - Lidos);
      Tof.Write(Buf, Tamanho - Lidos);
      Lidos:= Lidos + (Tamanho - Lidos);
    end;
    G.Progress:= ToF.Size;
    Application.ProcessMessages;
  until Lidos >= Tamanho;
  FreeAndNil(FromF);
  FreeAndNil(ToF);
end;

procedure JuntaArquivoComGauge(Arquivo, Origem: String; var Gtot, Gparc: TGauge);
const
  TamBufLocal = 4*2048;
var
  Buffer: array[0..TamBufLocal-1] of char;
  FromF, ToF: TFileStream;
  QtdLidos: int64;
  Ext, Ext2, NomeArqOri: string;
  PodeContinuar: Boolean;
begin
  NomeArqOri:= Origem;
  Tof:= TFileStream.Create(Arquivo, fmCreate);
  FromF:= TFileStream.Create(NomeArqOri, fmOpenRead);
  Gparc.MinValue:= 0;
  Gparc.MaxValue:= FromF.Size;
  Gparc.Progress:= 0;
  while FromF.Position < FromF.Size do
  begin
    QtdLidos:= FromF.Read(Buffer, TamBufLocal);
    Tof.Write(Buffer, QtdLidos);
    Gparc.AddProgress(QtdLidos);
    Application.ProcessMessages;
    if (FromF.Position >= FromF.Size) and (Ext <> '.ZUU') then
    begin
      FreeAndNil(FromF);
      Ext:= copy(NomeArqOri, length(NomeArqOri)-3,4);
      Ext:= '.Z'+strzero(strtoint(copy(Ext,3,2))+1,2);
      NomeArqOri:= copy(NomeArqOri, 1, length(NomeArqOri)-4);
      PodeContinuar:= false;
      while not PodeContinuar do//encheu o disco....
        if Application.MessageBox('Troque o disco e tecle OK para continuar...', 'BackUp', mb_okcancel) = mrcancel then
        begin
          FreeAndNil(ToF);
          exit;
        end//if Application.MessageBox('
        else
        begin
          if FileExists(NomeArqOri+Ext) then
          begin
            PodeContinuar:= true;
            NomeArqOri:= NomeArqOri+Ext;
          end
          else
          begin
            if FileExists(NomeArqOri+'.ZUU') then
            begin
              PodeContinuar:= true;
              Ext:= '.ZUU';
              NomeArqOri:= NomeArqOri+Ext;
            end;
          end;
          if PodeContinuar then
          begin
            FromF:= TFileStream.Create(NomeArqOri, fmOpenRead);
            Gparc.MinValue:= 0;
            Gparc.MaxValue:= FromF.Size;
            Gparc.Progress:= 0;
          end;
        end;//else
    end;
  end;//while FromF.Position < FromF.Size do
  FreeAndNil(FromF);
  FreeAndNil(ToF);
end;//procedure JuntaArquivo(Arquivo, Origem: String; var Gtot, Gparc: TGauge);

procedure DivideArquivoComGauge(Arquivo, Destino: String; var Gtot, Gparc: TGauge);
const
  TamBufLocal = 4*2048;
var
  Buffer: array[0..TamBufLocal-1] of char;
  FromF, ToF: TFileStream;
  NomeArqDest: string;
  EspacoLivre, Gravados, QtdGravados: int64;
  Ext: string;
  PodeContinuar: Boolean;
begin
  EspacoLivre:= getEspacoLivre(Destino);
  FromF:=TFileStream.Create(Arquivo, fmOpenRead);
  Gtot.MinValue:= 0;
  Gtot.MaxValue:= FromF.Size;
  Ext:= 'Z01';
  NomeArqDest:= addBackSlash(Destino)+copy(ExtractFileName(Arquivo),1,length(ExtractFileName(Arquivo))-3)+Ext;
  while FromF.Position < FromF.Size do//
  begin
    Gparc.MinValue:= 0;
    if (FromF.Size-FromF.Position) > EspacoLivre then
      Gparc.MaxValue:= EspacoLivre
    else
      Gparc.MaxValue:= FromF.Size-FromF.Position;
    Gparc.Progress:= 0;
    Gravados:= 0;
    NomeArqDest:= addBackSlash(Destino)+copy(ExtractFileName(Arquivo),1,length(ExtractFileName(Arquivo))-3)+Ext;
    ToF:= TFileStream.Create(NomeArqDest, fmCreate);
    while (Gravados < EspacoLivre) and (FromF.Position < FromF.Size) do
    begin
      if (EspacoLivre - Gravados) > TamBufLocal then//ainda cabe no disco o buffer inteiro...
      begin
        QtdGravados:= FromF.Read(Buffer, TamBufLocal);
        ToF.Write(Buffer, QtdGravados);
        Gravados:= Gravados+ QtdGravados;
      end
      else//tem que diminuir o buffer q vai ser gravado...
      begin
        QtdGravados:= FromF.Read(Buffer, EspacoLivre - Gravados);
        ToF.Write(Buffer, QtdGravados);
        Gravados:= Gravados+ QtdGravados;
      end;//if (EspacoLivre - Gravados) > TamBufLocal then
      Gparc.AddProgress(TamBufLocal);
      Gtot.AddProgress(TamBufLocal);
    end;//while Gravados < EspacoLivre do
//    Gtot.AddProgress(Gravados);
    FreeAndNil(ToF);
    if Ext <> 'ZUU' then
      PodeContinuar:= false
    else
    begin
      FreeAndNil(FromF);
      exit;
    end;
    while not PodeContinuar do//encheu o disco....
      if Application.MessageBox('Troque o disco e tecle OK para continuar...', 'BackUp', mb_okcancel) = mrcancel then
      begin
        FreeAndNil(FromF);
        exit;
      end//if Application.MessageBox('
      else
      begin
        EspacoLivre:= getEspacoLivre(Destino);
        if EspacoLivre > TamBufLocal then//trocou de disco...
        begin
          PodeContinuar:= true;
          if (FromF.Size-FromF.Position) < EspacoLivre then//? o ultimo disco...
            Ext:= 'ZUU'
          else
            Ext:= 'Z'+strzero(strtoint(copy(Ext,2,2))+1,2);
        end;//if EspacoLivre > TamBufLocal then//trocou de disco...
      end;//else
  end;//while FromF.Position < FromF.Size do//
end;//procedure DivideArquivo(Arquivo, Destino: String; var G: TGauge);

function GetTamArquivo(narq: string): int64;
var
  arq: TFileStream;
begin
  result:= 0;
  if fileexists(narq) then
  begin
    arq:= TFileStream.Create(narq, fmOpenRead);
    result:= arq.Size;
    FreeAndNil(arq);
  end;
end;
function Diferenca_em_Segundos_hhmmss(horaini,horafim:string):integer;
var
  t1,t2,h1,m1,s1,h2,m2,s2:integer;
begin
  h1:= strtointdef(copy(horaini,1,2),0);
  m1:= strtointdef(copy(horaini,3,2),0);
  s1:= strtointdef(copy(horaini,5,2),0);
  h2:= strtointdef(copy(horafim,1,2),0);
  m2:= strtointdef(copy(horafim,3,2),0);
  s2:= strtointdef(copy(horafim,5,2),0);
  t1:=h1*3600+m1*60+s1;
  t2:=h2*3600+m2*60+s2;
  if t1<=t2 then// nao rodou meia noite
    Result:= t2-t1
  else//rodou meia noite
    Result:= t2-t1+24*3600;
end;

function PoeNaLixeira (Handle:tHandle;nomearq:string):boolean;//tem que incluir ShellApi no uses
var
  Arqs,ArqsDst:string;
  i,j:integer;
  ShFileOpStruct : TShFileOpStruct;
begin
  try
    Arqs := nomearq+#0;
    Arqs := Arqs + #0#0;
    ArqsDst := ArqsDst + #0#0;
    FillChar(ShFileOpStruct,Sizeof(TShFileOpStruct),0);
    with ShFileOpStruct do begin
      Wnd := Handle;
      wFunc := FO_DELETE;
      pFrom := PChar(Arqs);
      pTo := PChar(ArqsDst);
      fFlags := FOF_ALLOWUNDO or FOF_SIMPLEPROGRESS or FOF_NOCONFIRMATION
         or FOF_MULTIDESTFILES;
    end;
    ShFileOperation(ShFileOpStruct);
    result:= true;
  except
    result:= false;
  end;
 //
end;

end.

(*function CalculaFrequenciaCard(Vet: array of smallint; amstela, TxAm:smallint): Single;
var
  i, ultimoincremento, periodo, qtdbat, valor, PosI, PosF: Integer;
  media: Double;
  incrementa: Boolean;
  F: TFiltro;
begin
  //configura um filtro para melhor definir as batidas do cardio
  F:= TFiltro.Create(TxAm,10,35,0,60);
  media:= 0;
  //calcula a altura media di cardio
  for i:= 0 to pred(amstela) do
  begin
    valor:= Vet[i];
    F.Integra(valor);
    Vet[i]:= valor;
    media:= media + abs(valor);
  end;//for i:= 0 to pred(amstela) do
  //espaco minimo entre uma batida e outra...
  periodo:= TxAm div 4;
  //media passa ser o limite para determinar uma batida.....
  media:= 4 * media / amstela;
  PosI:= -1;
  PosF:= -1;
  qtdbat:= 0;
  ultimoincremento:= 0;
  incrementa:= true;
  for i:= 0 to pred(amstela) do
  begin
    if not incrementa then
      if i > (ultimoincremento+periodo) then//verifica c a distancia do ultimo incremento ja ultrapassou o limite.
        incrementa:= true;
    if Vet[i] > media then//passou da altura, ? uma batida!
      if incrementa then
      begin
        if PosI < 0 then
          PosI:= i;
        inc(qtdbat);
        ultimoincremento:= i;
        incrementa:= false;
        PosF:= i;
      end;//if incrementa then
  end;//for i:= 0 to pred(amstela) do
  FreeAndNil(F);
  //calcula as batidas por minuto d devolve no result da funcao
  if PosF-PosI > 0 then
    result:= ((qtdbat-1) * 60) / ({amstela}(PosF-PosI) / TxAm)
  else
    result:= 0;
end;*)


