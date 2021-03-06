unit Filtros;

interface

Uses
  SysUtils, Dialogs;

type
  AInteger = Array of Integer;
  ADouble  = Array of Double;

  TipoFilt = (LOWPASS,HIPASS,BANDPASS,NOTCH);
  FiltroZ = class(TObject)
  private
    yn,          { saida do filtro Z no instante nT: y[nT]        }
    ynm1,        { saida do filtro Z em (n-1)T: y[(n-1)T]         }
    ynm2,        { saida do filtro Z em (n-2)T: y[(n-2)T]         }
    un,          { entrada do filtro Z em nT: u[nT]               }
    unm1,        { entrada do filtro Z em (n-1)T: u[(n-1)T]       }
    unm2,        { entrada do filtro Z em (n-2)T: u[(n-2)T]       }
    a,b,c,d,e : Double;         { Parāmetros do Filtro Z }
  public
    Constructor Create(Freqsamp,FreqCrt : Single;Tipo : TipoFilt); virtual;
    Constructor Init(const Flt :FiltroZ);
    Procedure Integra(var U : Integer); overload;
    Procedure Integra(var APt : AInteger); overload;
    Procedure Integra(var U : double); overload;
    Procedure Integra(var APt : Adouble); overload;
  end;

  PFiltro = ^TFiltro;
  TFiltro = class(TObject)
  private
    LowFlt,HighFlt,BandFlt,NotchFlt : FiltroZ;
  public
    FreqLow,FreqHigh,FreqCenter,FreqNotch : Double;
    Constructor Create(FreqSamp,FreqLo,FreqHi,FreqCent,FreqNtc: Single); overload;
    Constructor Create(var Flt : TFiltro); overload;
    Constructor Init(var Flt : TFiltro);
    Destructor Destroy; override;
    Procedure Integra(var U : Integer); overload;
    Procedure Integra(APt : AInteger); overload;
    Procedure Integra(var U : Double); overload;
    Procedure Integra(APt : ADouble); overload;
  end;

  TFilTipo = class(TFiltro)
  public
    Tipo : Char;
  end;

const
  PI       = 3.141592657;
  XSI      = 0.7071067811865;

implementation

Constructor FiltroZ.Create(FreqSamp,FreqCrt : Single;Tipo : TipoFilt);
var
  wn,t,aux1,aux2,aux3,Xsi1 : Double;
begin
  inherited Create;
  wn := 2.0*PI*FreqCrt;
  t  := 1.0/FreqSamp;
  XSI1 := 0.1;

  yn   := 0.0;
  ynm1 := 0.0;
  ynm2 := 0.0;
  un   := 0.0;
  unm1 := 0.0;
  unm2 := 0.0;
  aux1 := exp(-XSI*wn*t)*cos(wn*t*sqrt(1-XSI*XSI));
  aux2 := exp(-XSI*wn*t)*sin(wn*t*sqrt(1-XSI*XSI));
  if Tipo = LOWPASS then begin
    a := 0;
    b := 0;
    c := 1 + aux1*aux1 + aux2*aux2 - 2*aux1;
    d := 2*aux1;
    e := -(aux1*aux1 + aux2*aux2);
  end
  else if Tipo = HIPASS then begin
    aux3 := (1+2*aux1+aux1*aux1+aux2*aux2)/4;
    a := 1*aux3;
    b := -2*aux3;
    c := 1*aux3;
    d := 2*aux1;
    e := -(aux1*aux1 + aux2*aux2);
  end
  else begin
    aux1 := exp(-XSI1*wn*t)*cos(wn*t*sqrt(1-XSI1*XSI1));
    aux2 := exp(-XSI1*wn*t)*sin(wn*t*sqrt(1-XSI1*XSI1));
    if Tipo = BANDPASS then begin
      a := 0;
      b := (cos(2*wn*t)-2*aux1*cos(wn*t)+aux1*aux1+aux2*aux2)/(cos(wn*t)-1)/2;
{     b := (1-exp(-XSI1*wn*t))*(1-exp(-XSI1*wn*t))*cos(wn*t)+2*exp(-XSI1*wn*t)*
              cos(wn*t)*cos(wn*t)-cos(2*wn*t)-exp(-2*XSI1*wn*t); }
      c := -b;
      d := 2*aux1;
      e := -(aux1*aux1 + aux2*aux2);
    end
    else begin
      a := 1;
      b := -2*cos(wn*t);
      c := 1;
      d := 2*aux1;
      e := -(aux1*aux1 + aux2*aux2);
    end;
  end;
end;

Procedure FiltroZ.Integra(var U : double);
begin
  { Armazena entradas do filtro Z      }
  unm2 := unm1;                   { u[(n-2)T] <- u[(n-1)T] 	   }
  unm1 := un;                     { u[(n-1)T] <- u[nT] 		   }
  { Armazena saidas do filtro Z        }
  ynm2 := ynm1;                   { y[(n-2)T] <- y[(n-1)T] 	   }
  ynm1 := yn;                     { y[(n-1)T] <- y[nT] 		   }

  un := U;                        { calcula nova entrada do filtro Z   }
  try
    yn := a*un + b*unm1 + c*unm2 + d*ynm1 + e*ynm2;  { saida do filtro Z }
  except
    on EInvalidOp do
      yn:= 0;
  end;

  try
    U := yn;//Trunc(yn);
  except
    On ERangeError do
      if yn < 0 then
        U := -High(Integer);
      else
        U := High(Integer);
  end;
end;

Procedure FiltroZ.Integra(var APt : Adouble);
var
  APt1 : ADouble;
  i : Integer;
begin
  SetLength(Apt1,Length(Apt));
  Move(Apt[0],Apt1[0],High(Apt)*Sizeof(Integer));
  for i := 2 to High(Apt1)-1 do
  try
    Apt[i] := {Trunc}(a*Apt1[i] + b*Apt1[i-1] + c*Apt1[i-2] + d*Apt[i-1] + e*Apt[i-2]);  { saida do filtro Z }
  except
    On ERangeError do
      if Apt1[i] < 0 then
        Apt[i] := -Maxint;
      else
        Apt[i] := MaxInt;
  end;
end;

procedure FiltroZ.Integra(var APt: AInteger);
var
  APt1 : AInteger;
  i : Integer;
begin
  SetLength(Apt1,Length(Apt));
  Move(Apt[0],Apt1[0],High(Apt)*Sizeof(Integer));
  for i := 2 to High(Apt1)-1 do
  try
    Apt[i] := Trunc(a*Apt1[i] + b*Apt1[i-1] + c*Apt1[i-2] + d*Apt[i-1] + e*Apt[i-2]);  { saida do filtro Z }
  except
    On ERangeError do
      if Apt1[i] < 0 then
        Apt[i] := -Maxint;
      else
        Apt[i] := MaxInt;
  end;
end;

procedure FiltroZ.Integra(var U : Integer);
begin
  { Armazena entradas do filtro Z      }
  unm2 := unm1;                   { u[(n-2)T] <- u[(n-1)T] 	   }
  unm1 := un;                     { u[(n-1)T] <- u[nT] 		   }

  { Armazena saidas do filtro Z        }
  ynm2 := ynm1;                   { y[(n-2)T] <- y[(n-1)T] 	   }
  ynm1 := yn;                     { y[(n-1)T] <- y[nT] 		   }

  un := U;                        { calcula nova entrada do filtro Z   }
(*EInvalidOp

EInvalidOp is the exception class for undefined floating-point operations.

EInvalidPointer

*)
//  yn := a*un + b*unm1 + c*unm2 + d*ynm1 + e*ynm2;  { saida do filtro Z }
  try
    yn := a*un + b*unm1 + c*unm2 + d*ynm1 + e*ynm2;  { saida do filtro Z }
  except
    on EInvalidOp do
      yn:= 0;
  end;

  try
    U := Trunc(yn);
  except
    On ERangeError do
      if yn < 0 then
        U := -High(Integer);
      else
        U := High(Integer);
  end;
end;

Constructor FiltroZ.Init(const Flt: FiltroZ);
begin
  inherited Create;
  yn   := 0.0;
  ynm1 := 0.0;
  ynm2 := 0.0;
  un   := 0.0;
  unm1 := 0.0;
  unm2 := 0.0;
  a := Flt.a;
  b := Flt.b;
  c := Flt.c;
  d := Flt.d;
  e := Flt.e;
end;

Constructor TFiltro.Create(FreqSamp,FreqLo,FreqHi,FreqCent,FreqNtc : Single);
begin
  inherited Create;
  LowFlt  := NIL;
  HighFlt  := NIL;
  BandFlt := NIL;
  NotchFlt := NIL;
  FreqLow := FreqLo;
  FreqHigh := FreqHi;
  FreqCenter := FreqCent;
  FreqNotch := FreqNtc;
  if (FreqCent <> 0.0) then begin
    if (FreqCent < FreqSamp/2) then
      BandFlt := FiltroZ.Create(FreqSamp,FreqCent,BANDPASS)
    else
      BandFlt := FiltroZ.Create(FreqSamp,FreqSamp/2,BANDPASS);
  end
  else begin
    if (FreqHi <> 0.0) then begin
      if (FreqHi < FreqSamp/2) then
        LowFlt := FiltroZ.Create(FreqSamp,FreqHi,LOWPASS)
      else
        LowFlt := FiltroZ.Create(FreqSamp,FreqSamp/2,LOWPASS);
    end;
    if (FreqLo <> 0.0) then begin
      if (FreqLo < FreqSamp/2) then
        HighFlt := FiltroZ.Create(FreqSamp,FreqLo,HIPASS)
      else
        HighFlt := FiltroZ.Create(FreqSamp,FreqSamp/2,HIPASS);
    end;
  end;
  if (FreqNtc <> 0) then begin
    if (FreqNtc < FreqSamp/2) then
      NotchFlt := FiltroZ.Create(FreqSamp,FreqNtc,NOTCH)
    else
      NotchFlt := FiltroZ.Create(FreqSamp,FreqSamp/2,NOTCH);
  end;
end;

Constructor TFiltro.Create(var Flt: TFiltro);
begin
  Init(Flt);
end;

Constructor TFiltro.Init(var Flt: TFiltro);
begin
  inherited Create;
  LowFlt  := NIL;
  HighFlt  := NIL;
  BandFlt := NIL;
  NotchFlt := NIL;
  if Flt.LowFlt <> NIL then
    LowFlt := FiltroZ.Init(Flt.LowFlt);
  if Flt.HighFlt <> NIL then
    HighFlt := FiltroZ.Init(Flt.HighFlt);
  if Flt.BandFlt <> NIL then
    BandFlt := FiltroZ.Init(Flt.BandFlt);
  if Flt.NotchFlt <> NIL then
    NotchFlt := FiltroZ.Init(Flt.NotchFlt);
end;

Destructor TFiltro.Destroy;
begin
  if LowFlt <> NIL then
    LowFlt.Destroy;
  if HighFlt <> NIL then
    HighFlt.Destroy;
  if BandFlt <> NIL then
    BandFlt.Destroy;
  if NotchFlt <> NIL then
    NotchFlt.Destroy;
  inherited Destroy;
end;

procedure TFiltro.Integra(var U : Double);
begin
  if NotchFlt <> NIL then
    NotchFlt.Integra(U);
  if BandFlt <> NIL then
    BandFlt.Integra(U);
  if LowFlt <> NIL then
    LowFlt.Integra(U);
  if HighFlt <> NIL then
    HighFlt.Integra(U);
end;

procedure TFiltro.Integra(APt : ADouble);
begin
  if NotchFlt <> NIL then
    NotchFlt.Integra(Apt);
  if BandFlt <> NIL then
    BandFlt.Integra(Apt);
  if LowFlt <> NIL then
    LowFlt.Integra(Apt);
  if HighFlt <> NIL then
    HighFlt.Integra(Apt);
end;

procedure TFiltro.Integra(var U : Integer);
begin
  if NotchFlt <> NIL then
    NotchFlt.Integra(U);
  if BandFlt <> NIL then
    BandFlt.Integra(U);
  if LowFlt <> NIL then
    LowFlt.Integra(U);
  if HighFlt <> NIL then
    HighFlt.Integra(U);
end;

procedure TFiltro.Integra(APt: AInteger);
begin
  if NotchFlt <> NIL then
    NotchFlt.Integra(Apt);
  if BandFlt <> NIL then
    BandFlt.Integra(Apt);
  if LowFlt <> NIL then
    LowFlt.Integra(Apt);
  if HighFlt <> NIL then
    HighFlt.Integra(Apt);
end;

end.




