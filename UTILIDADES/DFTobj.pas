unit DFTobj;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

const
  MaxFFTArraySize = 1024;
  TamSenoide      = 100;//1000;

type
  longreal = double;
  complex  = record
    re, im: longreal;
  end;

  FFTArray    = array[0..MaxFFTArraySize-1] of complex;
  FFTArrayPtr = ^FFTArray;

var
//  twid                : FFTArrayPtr;
  twid                : FFTArray;
  CurrentFFTArraySize : integer;


type
  TNumCompl = record
    real :double;
    imag :double;
  end;//Tomplexo

  PSinalum = ^TSinalum;
  TSinalum = Array of double;

  PSinal = ^TSinal;
  TSinal = Array [0..1] of TSinalum;

  PModuloFFT = ^TModuloFFT;
  TModuloFFT = array of double;//[0..Pred(256)]

  procedure SetupTwid(NewFFTarraySize:integer);
  procedure  fft(c:FFTArrayPtr; N:integer);
  procedure ifft(c:FFTArrayPtr; N:integer);

Type
//  Tsenoide = array[0..6283] of double;
  Tsenoide = array[0..round(TamSenoide*2*pi)] of double;

Type

  TDFT = class (TObject)
  private
    vetor        : array of TNumCompl;
    senoide      : Tsenoide;
    TamanhoEpoca : integer;
    MediaMovel   : Boolean;
    procedure getRe (var vet: array of double);
    procedure getIm (var vet: array of double);
    Procedure getMod(var vet: array of double);
    procedure CalculaD(aentrada : array of double; fAm: single; fMaxHz: double);
    procedure CalculaF(aentrada : array of double);
  public
    lModuloFFT : array of double;
    lXIm       : array of double;
    lXRe       : array of double;
    constructor Create;
    destructor  destroy; override;
    procedure   Calcula(umaentrada : array of double;umaMediaMovel:boolean; fAm: single; fMaxHz: double; alfa: single = 0.1);
    function iDFT(var real,imag,serieTemp: array of double): double;
  end;//TDFT


implementation

uses Math;
{ TDFT }

constructor TDFT.Create;
var
  i , limite :integer;
begin
  //  preenche o vetor senoide
  limite:= high(senoide);
  for i:= 0 to limite do
      senoide[i]:= sin(i/TamSenoide);
//  new(twid);
end;

procedure TDFT.Calcula(umaentrada: array of double; umaMediaMovel: boolean; fAm: single; fMaxHz: double; alfa: single);
Var
   i, lim:integer;
   soma, paratukey: single;
begin
  MediaMovel := umaMediaMovel;
  TamanhoEpoca := high(umaentrada)+1;
  // Retira DC
  soma := 0;
  for i := 0 to pred(TamanhoEpoca) do
    soma := soma + umaentrada[i];
  soma := soma/TamanhoEpoca;
  for i := 0 to pred(TamanhoEpoca) do
    umaentrada[i] := umaentrada[i] - soma;
  // lanela tukey
//  alfa := 0.1;
  lim := round(alfa*pred(TamanhoEpoca)/2);
  for i := 0 to lim do
  begin
    paratukey := 0.5*(1+cos(pi*(2*i/(alfa*pred(TamanhoEpoca))-1) ));
    umaentrada[i] := umaentrada[i] * paratukey;
    umaentrada[pred(TamanhoEpoca)-i] := umaentrada[pred(TamanhoEpoca)-i] * paratukey;
  end;//for

  if (Frac(Log2(TamanhoEpoca)) = 0) and (TamanhoEpoca <= MaxFFTArraySize) then
    CalculaF(umaentrada) // pode ser FFT
  else
    CalculaD(umaentrada, fAm, fMaxHz);// Tem que ser DFT
end;
procedure TDFT.CalculaF(aentrada : array of double);
Var
  i, tamvet:integer;
  umFFTArray : FFTArray;
begin
//
//  SetupTwid(TamanhoEpoca);
  tamvet := TamanhoEpoca div 2;
  if high(vetor)+1 <> tamvet then
    setlength(vetor , tamvet);

  for i := 0 to pred(TamanhoEpoca) do
  begin
    umFFTArray[i].re := aentrada[i];
    umFFTArray[i].im := 0;
  end;
  fft(@umFFTArray, TamanhoEpoca);
  for i := 0 to TamanhoEpoca div 2 do
  begin
    vetor[i].imag := umFFTArray[i].re *2;// O autor da rotina fez uma pegadinha.
    vetor[i].real := -umFFTArray[i].im *2;// *2 pqo sinal de entrada ? sempre real
  end;
  if high(lModuloFFT)+1 <> tamvet then
    SetLength(lModuloFFT,tamvet);
  getMod(lModuloFFT);
  if high(lXRe)+1 <> tamvet then
    SetLength(lXRe,tamvet);
  getRe(lXRe);
  if high(lXIm)+1 <> tamvet then
    SetLength(lXIm,tamvet);
  getIm(lXIm);
end;

procedure TDFT.CalculaD(aentrada : array of double; fAm: single; fMaxHz: double);

var
k, n , tamvet, limite :integer;
pi2, _2pi ,k_N, angulo: double;
begin
  pi2 := (pi/2);
  _2pi:= (2*pi);
//calcula TamVet
//  tamvet := TamanhoEpoca div 2;
  tamvet:= round(fMaxHz * TamanhoEpoca / fAm);
  limite := high(senoide);
  if high(vetor)+1 <> tamvet then
    setlength(vetor , tamvet);
  for k := 0 to pred(tamvet) do// div 2 pq o sinal de entrada ? sempre real
  begin
    vetor[k].real:=0;
    vetor[k].imag:=0;
    k_N := k/TamanhoEpoca;
    for n := 0 to pred(TamanhoEpoca) do
    begin
      angulo := _2pi*frac(n*k_N);
      vetor[k].imag := vetor[k].imag + aentrada[n]*senoide[round(TamSenoide*(angulo))];
//      vetor[k].real := vetor[k].real + aentrada[n]*senoide[round(TamSenoide*(angulo))];

      angulo := (pi2+angulo);// ang do cosseno
      if TamSenoide*angulo >= limite then
        angulo := (angulo - (limite/TamSenoide));
      vetor[k].real := vetor[k].real + aentrada[n]*senoide[round(TamSenoide*(angulo))];
//      vetor[k].imag := vetor[k].imag + aentrada[n]*senoide[round(TamSenoide*(angulo))];

    end; // for n := 0 to pred(tamvet) do
    vetor[k].real := vetor[k].real *2; // o sinal de entrada ? sempre real
    vetor[k].imag := vetor[k].imag *2; // o sinal de entrada ? sempre real
  end; // for k := 0 to pred(tamvet) do
  if high(lModuloFFT)+1 <> tamvet then
    SetLength(lModuloFFT,tamvet);
  getMod(lModuloFFT);
  if high(lXRe)+1 <> tamvet then
    SetLength(lXRe,tamvet);
  getRe(lXRe);
  if high(lXIm)+1 <> tamvet then
    SetLength(lXIm,tamvet);
  getIm(lXIm);
end; //procedure TDFT.Calcula(umaentrada: array of double; umaMediaMovel: boolean);

procedure TDFT.getIm(var vet: array of double);
var n, limite : integer;
begin
  limite := high(vetor);
  if limite > high(vet) then
    limite := high(vet) + 1;
  for n := 0 to limite do
    vet[n] := vetor[n].imag;
end;

procedure TDFT.getMod(var vet: array of double);
var n, limite : integer;
begin
  limite := high(vetor);
  if limite > high(vet) then
    limite := high(vet) + 1;
  if MediaMovel then
  begin
    for n := 1 to pred(limite) do
      vet[n] := (sqrt(sqr(vetor[n-1].real)+sqr(vetor[n-1].imag))
                 +sqrt(sqr(vetor[n].real)+sqr(vetor[n].imag))
                 +sqrt(sqr(vetor[n+1].real)+sqr(vetor[n+1].imag)))/3;
    vet[0] := 0; // n?o tem DC
    vet[limite] := vet[limite-1]; //
  end
  else
    for n := 0 to limite do
      vet[n] := sqrt(sqr(vetor[n].real)+sqr(vetor[n].imag));
end;

procedure TDFT.getRe(var vet: array of double);
var n, limite : integer;
begin
  limite := high(vetor);
  if limite > high(vet) then
    limite := high(vet) + 1;
  for n := 0 to limite do
    vet[n] := vetor[n].real;
end;

function TDFT.iDFT(var real, imag, serieTemp: array of double): double;
var I,J : integer;
    Ampl,Fase : Array of double;
begin
  Result := -1;
  SetLength(Ampl,succ(high(real)));
  SetLength(Fase,succ(high(real)));
  for J := Low(real) to High(real) do
  begin
    Ampl[j] := sqrt(sqr(real[j]) + sqr(imag[j]));
    Fase[j] := 0; //***************************AQUI 888888888888888888888
  end;
  if (high(real) <> high(real)) or (succ(high(real))*2 <> succ(high(serieTemp))) then
    exit;

  for I := Low(serieTemp) to High(serieTemp) do
  begin
    for J := Low(real) to High(real) do
         ;
  end;
end;

//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
 procedure SetupTwid(NewFFTarraySize:integer);
    var
      j:integer;
      h:longreal;
    begin
 //      if not (NewFFTarraySize = CurrentFFTArraySize) then
         begin
         // coloquei para que pudesse rodar
         //    if twid <> nil then
         //      dispose(twid);
         //    new(twid);
         //
             h := 2*pi/NewFFTarraySize;
             for j := 0 to (NewFFTarraySize div 2) - 1 do
               begin
//                 twid^[j].re := cos(j*h);
//                 twid^[j].im := -sin(j*h);
                 twid[j].re := cos(j*h);
                 twid[j].im := -sin(j*h);
               end;
            CurrentFFTArraySize := NewFFTarraySize;
          end;
    end;

 function Cadd(a, b:complex):complex;
	var c:complex;
	 begin 
	   c.re:=a.re + b.re;
	   c.im:=a.im + b.im;
	   Cadd := c;
	 end;
	
 function Csub(a,b: complex):complex;
	var c:complex;
	 begin 
       c.re := a.re - b.re;
	   c.im := a.im - b.im;
	   Csub := c;
	 end;

 function Cmul(a,b:complex):complex;
	var c:complex;
	 begin 
        c.re := a.re * b.re - a.im * b.im;
        c.im := a.im * b.re + a.re * b.im;
		Cmul := c;
	 end;

 function Comp(a,b:longreal):complex;
	var c:complex;
	 begin 
		c.re := a;
		c.im := b;
		Comp := c;
	 end;
	
 function Cdiv(a, b:complex):complex;
	var c:complex;
	    mod2:longreal;
	 begin 
       mod2 := sqr(b.re) + sqr(b.im);
       c.re :=(a.re * b.re + a.im * b.im)/mod2;
       c.im :=(a.im * b.re - a.re * b.im)/mod2;
	   Cdiv := c;
	 end;
	
 function RCmul(a:longreal; b:complex):complex;
	var c:complex;
	 begin 
       c.re := a * b.re;
       c.im := a * b.im;
	   Rcmul := c;
	 end;
		
 function Cexp(x,y:longreal):complex;
	 var c:complex;
	  begin 
        c.re:= exp(x)*cos(y);
        c.im:= exp(x)*sin(y);
	    cexp := c;
	  end;
	
	
 function Cconjg(c:complex):complex;
	var d:complex;
	  begin 
        d.re :=   c.re;
	    d.im := - c.im;
	    Cconjg := d;
	  end;
	
 function Cabs(c:complex):longreal;
	var d:longreal;
	 begin 
         d:=sqrt(c.re * c.re + c.im * c.im);
	     Cabs := d;
	 end;
	
 function Cexpi(y:longreal):complex;
	var c:complex;
	 begin 
       c.re := cos(y);
       c.im := sin(y);
	   Cexpi :=  c;
	 end;



 procedure fft( c:FFTArrayPtr; N:integer);      		  (* fft *)
 
	 var 
	    i,j,bit:integer;
	    numtrans,sizetrans,halfsize:integer;
	    ind,sub:integer;
	    iminus,iplus:integer;
	    twiddle:complex;
	    but1,but2:complex;
	    temp:complex;

	 begin   
	    SetupTwid(N);              
        i:=0;   										  (* bit reversal *)
	    for j:=1 to N - 1 do   							  (* count with j *)	 
	        begin 										  (* binary add 1 to i in mirror *)
              bit:=N div 2;
	          while ( i >= bit ) do   					  (* until you encounter 0, change 1 to 0 *)
	             begin 
                   i:=i-bit;
	               bit:=bit div 2; 
	            end;
	          i := i+bit;		         				  (* then change 0 to 1 *)
	          if  (i<j) then 
	            begin 
                 temp:=c^[i]; c^[i]:=c^[j]; c^[j]:=temp;  (* swap once for each pair *)
	            end;
	        end;

	   numtrans := N;
	   sizetrans := 1;

	  while (numtrans > 1) do  
	    begin 
          numtrans := numtrans div 2;                      (* at each level, do half as many *)
	      halfsize := sizetrans;
	      sizetrans:= 2 * sizetrans;                       (* subtransforms of twice the size *)
	      for ind := 0  to  halfsize - 1 do                (* index in each subtransform *)
	        begin 
//              twiddle := twid^[ind * numtrans];	           (* sharing common twiddle *)
              twiddle := twid[ind * numtrans];	           (* sharing common twiddle *)
	          for sub :=0 to numtrans -1  do               (* index of subtransform *)
	             begin
                   iplus:=sub * sizetrans + ind;           (* indices for butterfly *)
	               iminus := iplus + halfsize;
	               but1 := c^[iplus];
	               but2 := Cmul(twiddle,c^[iminus]);        (* lower one gets twiddled *)
	               c^[iplus]  :=  Cadd(but1,but2);          (* butterfly *)
	               c^[iminus] :=  Csub(but1,but2);
	             end;
	        end;
	   end;
  end;


 procedure ifft(c:FFTArrayPtr; N:Integer);                  (* inverse fft *)
	var k:integer;
	    Ninv:longreal;
	 begin 
	    SetupTwid(N);  
        Ninv:=1.0/N;	
	    for k:= 0 to N - 1 do
	       c^[k]:=Cconjg(c^[k]);
	    fft(c,N);
	    for k:=0 to N - 1 do 
	        c^[k]:=RCmul(Ninv,Cconjg(c^[k]));
     end;

destructor TDFT.destroy;
begin
  inherited;
{  if twid <> nil then
  begin
    dispose(twid);
    twid:= nil;
  end;}
  setlength(lModuloFFT,0);
  setlength(lXIm,0);
  setlength(lXRe,0);
end;

end.

