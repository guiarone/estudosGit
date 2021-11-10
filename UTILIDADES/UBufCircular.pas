unit UBufCircular;

interface

Const
TamB = 1000;
// As ctes abaixo se referem à PCI da SISO
SISOCabec = 'O';
SISOId1  =  'c';
SISOId2 = 'v';
SISOTamPac1 = 4;
SISOTamPac2 = 7;
// As ctes abaixo se referem à PCI da NONIN
NONINCabec = char(1);
NONINId1  =  char(1);
NONINId2 = char(0);
NONINTamPac = 5; 

Type

Tbuf = array [0..pred(TamB)] of byte;
Pbuf = ^Tbuf;


TBC = class(TObject)
  protected
  BC, Bsaida : Pbuf;
  PosIns,PosRet : Integer;
  FQtdBytes : integer;
  function getQtdBytes() : integer;
  Function AumentaCont(pa:integer) : integer;

  public
  Function ReceberBytes(entrada : Pbuf; qtd : integer) : Integer;
  Function ReceberByte(entrada : Byte) : Integer;
  Function InformaByte(Pos : word): byte;
  Function InformaBytes(Quantos:integer): Pbuf;
  Function RetiraBytes(Quantos:integer): Pbuf;
  property QtdBytes : integer  read getQtdBytes;
  property Pret : integer read PosRet;
  property Pins : integer read PosIns;
  Constructor Create;
  Destructor Destroy; override;
end;
//var
//UmBC : TBC;
implementation

Function TBC.ReceberBytes(entrada : Pbuf; qtd : integer) : Integer;
var
  I, posicao : integer; //, qtd
  BufLocal : Pbuf;
begin
  if (qtd > 0) then
  begin
    posicao := PosIns;
    for i := 0 to pred(qtd) do
    begin
      BC[posicao] := entrada[i];
      posicao := AumentaCont(posicao);
    end;
    PosIns := posicao;
  end;
  Result := 0;
end;

function TBC.ReceberByte(entrada: Byte): Integer;
begin
  BC[PosIns] := entrada;
  PosIns := AumentaCont(PosIns);
end;
//}
Function TBC.AumentaCont(pa:integer) : integer;
var i : integer;
begin

  if pa < Pred(SizeOf(Tbuf)) then
  begin
    i := Pa + 1;
  end
  else
    i := 0;
  Result := i;
end;

Function TBC.InformaByte(Pos : word): byte;
var
  i, posicao, qtd: integer;
begin
  qtd := Pos;
  posicao := PosRet;
  for i := 0 to pred(qtd) do
    posicao :=  AumentaCont(posicao);
  Result := BC[posicao];
end;



Function TBC.RetiraBytes(Quantos:integer): Pbuf;
var i : integer;
begin
  if Quantos > getQtdBytes then
    Quantos := getQtdBytes;
  Result := InformaBytes(Quantos);
  for i := 1 to Quantos do
    PosRet :=AumentaCont(PosRet);
  //PosRet := PosIns;
end;
Function TBC.InformaBytes(Quantos:integer): Pbuf;
var
  i, posicao, qtd: integer;
begin
  qtd := getQtdBytes();
  if Quantos < qtd then qtd := Quantos;
  posicao := PosRet;
  for i := 0 to pred(qtd) do
  begin
    Bsaida[i] := BC[posicao];
    posicao :=  AumentaCont(posicao);
  end;
  Result := Bsaida;
end;

function TBC.getQtdBytes() : Integer;
begin
  if PosIns >= PosRet then
    Result := PosIns - PosRet
  else
    Result := Sizeof(TBuf) + PosIns - PosRet;
  //if result > 10 then
  //  result := 10;
end;

Constructor TBC.Create;
begin
  GetMem(BC,Sizeof(Tbuf));
  GetMem(Bsaida,Sizeof(Tbuf));
  PosIns := 0;
  PosRet := 0;
  //GetMem(BufLocal,Sizeof(Tbuf));
end;

Destructor TBC.Destroy;// overload;
begin
  inherited ;
  FreeMem(BC,Sizeof(Tbuf));
  FreeMem(Bsaida,Sizeof(Tbuf));
end;

end.
