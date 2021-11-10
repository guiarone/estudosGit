
(*
    Complex.pas
    Kjell Rilbe
    First public release: 31 Jan 2000

    The complex number unit is now more or less finished. I've implemented
    sin, cos, tan, cotan, sinh, cosh, tanh, cotanh and all eight corresponding
    arcus functions, as well as negation, conjugate, comparison and
    assignment. The hyperbolic functions and the arcus functions have not
    really been tested (no time right now). Please, please, please let me know
    if there's anything wrong with them!!!

    What's missing now is better string conversion routines. The ones I made
    were rather ambitious I thought, but I've seen that they've got some
    problems. Let me know what you think, and give me some ideas on how to
    improve them! Also, if you're missing any math functions, please let me
    know and I'll see what I can do.

    The member operations are procedures in my class, operating on and
    changing the value of the object itself. If you want to build expressions
    with nested function calls, use the stand-alone functions instead. I've
    used them in some of my member operation implementations. I chose this
    scheme to make things clean and simple.

    In the same spirit, I have not implemented aliases for the same operations,
    not even as properties. So, for the modulus, I only have the R (radius)
    property, no Norm, Modulus, Absolute etc. Just the R.

    Please feel free to suggest improvements.  Anyone can modify the code as
    they please, but I would appreciate if they send their changes to me, so
    that I can incorporate them if I think they're good.  (With due credit of
    course!)

    Kjell Rilbe <krilbe@tjohoo.se>
*)


unit Complex;
{ The argument returned by TComplex is always in the interval [-pi,pi). }

{ As default, Extended is used for all numbers. To set other precision, define }
{ UseSingle, UseDouble or UseReal. The type used is aliased by the type CReal. }

interface

type
  { Define the type to be used for real numbers in this unit. }
//  {$DEFINE UseDouble}
{$ifdef UseSingle}
  CReal = Single;
{$else}
  {$ifdef UseDouble}
  CReal = Double;
  {$else}
    {$ifdef UseReal}
  CReal = Real;
    {$else}
  CReal = Extended;
    {$endif}
  {$endif}
{$endif}

  { The complex number class. }
  TComplex = class
    constructor Create;                         { Init to zero }
    constructor CreateRect(Re,Im:CReal);        { Init with real and imaginary }
    constructor CreatePolar(R,Arg:CReal);       { Init with radius and argument }
    constructor CreateComplex(z:TComplex);      { Init from another TComplex }
    function FormatStr(                         { Return string representation }
      const Format : string;    { %r=re, %i=im, %R=r, %A=arg(deg), %a=arg(rad), %%=% }
      const Width  : Byte;      { Width for each inserted number }
      const Dec    : Byte       { Decimals for each inserted number }
    ) : string;
    procedure FormatVal(                        { Get complex value from string }
      const s      : string;    { The string containing the complex number }
      const Format : string     { Same tags as Str, but only re & im or r & arg }
    );
    procedure Assign(z:TComplex);               { assign z to self }
    function  Equals(z:TComplex) : Boolean;     { compare self with z }
    function  Differs(z:TComplex) : Boolean;    { compare self with z }
    procedure Negate;                           { Negate self }
    procedure Conjugate;                        { Conjugate self }
    procedure Add(z:TComplex);                  { add z to self }
    procedure Subtract(z:TComplex);             { subtract z from self }
    procedure Multiply(z:TComplex);             { multiply self by z }
    procedure Divide(z:TComplex);               { divide self by z }
    procedure Invert;                           { invert self }
    procedure Sqr;                              { square self }
    procedure Sqrt;                             { set self to its square root }
    procedure Ln;                               { set self to its logarithm }
    procedure Exp;                              { set self to its exponential }
    procedure Log(a:TComplex);                  { set self to its a-logarithm }
    procedure Power(a:TComplex);                { set self to its a-power: z^a = exp(a*ln(z))  }
    procedure Sin;                              { set self to its sine }
    procedure Cos;                              { set self to its cosine }
    procedure Tan;                              { set self to its tangent }
    procedure Cotan;                            { set self to its cotangent }
    procedure ArcSin;                           { set self to its arcsine }
    procedure ArcCos;                           { set self to its arccosine }
    procedure ArcTan;                           { set self to its arctangent }
    procedure ArcCotan;                         { set self to its arccotangent }
    procedure Sinh;                             { set self to its sinhyp }
    procedure Cosh;                             { set self to its coshyp }
    procedure Tanh;                             { set self to its tanhyp }
    procedure Cotanh;                           { set self to its cothyp }
    procedure ArcSinh;                          { set self to its arcsinhyp }
    procedure ArcCosh;                          { set self to its arccoshyp }
    procedure ArcTanh;                          { set self to its arctanhyp }
    procedure ArcCotanh;                        { set self to its arccothyp }
  private
    FRe  : CReal;                               { Real part }
    FIm  : CReal;                               { Imaginary part }
    FR   : CReal;                               { Radius (absolute value) }
    FArg : CReal;                               { Argument }
    FRectValid  : Boolean;                      { True if FRe and FIm are up to date }
    FPolarValid : Boolean;                      { True if FR and FArg are up to date }
    function  CalcArg : CReal;                  { Calc & return arg from re & im }
    procedure CalcRect;                         { Calc & set re & im from r & arg }
    procedure CalcPolar;                        { Calc & set r & arg from re & im }
    function  GetRe  : CReal;                   { Read re , even if not FRectValid  }
    function  GetIm  : CReal;                   { Read im , even if not FRectValid  }
    function  GetR   : CReal;                   { Read r  , even if not FPolarValid }
    function  GetArg : CReal;                   { Read arg, even if not FPolarValid }
    procedure SetRe(NewRe  :CReal);             { Change re , without changing im  }
    procedure SetIm(NewIm  :CReal);             { Change im , without changing re  }
    procedure SetR (NewR   :CReal);             { Change r  , without changing arg }
    procedure SetArg(NewArg:CReal);             { Change arg, without changing r   }
  public
    property Re  : CReal read GetRe  write SetRe ; { Get/set re without changing im }
    property Im  : CReal read GetIm  write SetIm ; { Get/set im without changing re }
    property R   : CReal read GetR   write SetR  ; { Get/set r without changing arg }
    property Arg : CReal read GetArg write SetArg; { Get/set arg without changing r }
  end;



function StrToComplexF(const s : string; const Format : string) : TComplex;
function CEq       (x,y:TComplex) : Boolean;
function CDiff     (x,y:TComplex) : Boolean;
function CNeg      (x  :TComplex) : TComplex;
function CConj     (x  :TComplex) : TComplex;
function CAdd      (x,y:TComplex) : TComplex;
function CSub      (x,y:TComplex) : TComplex;
function CMul      (x,y:TComplex) : TComplex;
function CDiv      (x,y:TComplex) : TComplex;
function CInv      (x  :TComplex) : TComplex;
function CSqr      (x  :TComplex) : TComplex;
function CSqrt     (x  :TComplex) : TComplex;
function CLn       (x  :TComplex) : TComplex;
function CExp      (x  :TComplex) : TComplex;
function CLog      (a,x:TComplex) : TComplex;
function CPow      (a,x:TComplex) : TComplex;
function CSin      (x  :TComplex) : TComplex;
function CCos      (x  :TComplex) : TComplex;
function CTan      (x  :TComplex) : TComplex;
function CCotan    (x  :TComplex) : TComplex;
function CArcSin   (x  :TComplex) : TComplex;
function CArcCos   (x  :TComplex) : TComplex;
function CArcTan   (x  :TComplex) : TComplex;
function CArcCotan (x  :TComplex) : TComplex;
function CSinh     (x  :TComplex) : TComplex;
function CCosh     (x  :TComplex) : TComplex;
function CTanh     (x  :TComplex) : TComplex;
function CCotanh   (x  :TComplex) : TComplex;
function CArcSinh  (x  :TComplex) : TComplex;
function CArcCosh  (x  :TComplex) : TComplex;
function CArcTanh  (x  :TComplex) : TComplex;
function CArcCotanh(x  :TComplex) : TComplex;



var
  COne      : TComplex;      {  1                  }
  CMinusOne : TComplex;      { -1                  }
  Ci        : TComplex;      {  i (imaginary unit) }
  CMinusi   : TComplex;      { -i                  }



implementation

uses
  SysUtils;

const
  Pi0_5 = 1.570796326794896619231321691640;        {   Pi/2 }
(*Pi1_5 = 4.712388980384689857693965074919;        { 3*Pi/2 }(* not used *)
  Pi2   = 6.283185307179586476925286766558;        { 2*Pi   }



{------------------------------------------------------------------------------------}
{ Constructors                                                                       }
{------------------------------------------------------------------------------------}

constructor TComplex.Create;
  begin
    inherited Create;
    FRe :=0;
    FIm :=0;
    FR  :=0;
    FArg:=0;
    FRectValid :=True;
    FPolarValid:=True;
  end;

constructor TComplex.CreateRect;
  begin
    inherited Create;
    FRe:=Re;
    FIm:=Im;
    FRectValid :=True ;
    FPolarValid:=False;
  end;

constructor TComplex.CreatePolar;
  begin
    inherited Create;
    FR  :=R  ;
    FArg:=Arg;
    FRectValid :=False;
    FPolarValid:=True ;
  end;

constructor TComplex.CreateComplex;
  begin
    inherited Create;
    Assign(z);
  end;



{------------------------------------------------------------------------------------}
{ Private helpers, miscellaneous                                                     }
{------------------------------------------------------------------------------------}

{ Calculates argument in the interval [-Pi,Pi) }
function TComplex.CalcArg;
  begin
    if FRe=0 then begin             { on imaginary axis }
      if FIm>0 then Result:= Pi0_5
               else Result:=-Pi0_5;
    end
    else begin
      Result:=System.ArcTan(FIm/FRe);
      if FRe<0 then begin
         if FIm>0 then Result:=Result+Pi
                  else Result:=Result-Pi;
      end;
    end;
  end;

{ Force valid re and im. The calculation is performed without checking FRectValid. }
procedure TComplex.CalcRect;
  begin
    FRe := FR * System.Cos(FArg);
    FIm := FR * System.Sin(FArg);
    FRectValid:=True;
  end;

{ Force valid r and arg. The calculation is performed without checking FPolarValid. }
procedure TComplex.CalcPolar;
  begin
    FR := System.Sqrt( FRe*FRe + FIm*FIm );
    FArg := CalcArg;
    FPolarValid:=True;
  end;



{------------------------------------------------------------------------------------}
{ Private property getters and setters                                               }
{------------------------------------------------------------------------------------}

function TComplex.GetRe;
  begin
    if not FRectValid then CalcRect;
    Result:=FRe;
  end;

function TComplex.GetIm;
  begin
    if not FRectValid then CalcRect;
    Result:=FIm;
  end;

function TComplex.GetR;
  begin
    if not FPolarValid then CalcPolar;
    Result:=FR;
  end;

function TComplex.GetArg;
  begin
    if not FPolarValid then CalcPolar;
    Result:=FArg;
  end;

procedure TComplex.SetRe;
  begin
    if not FRectValid then CalcRect;
    FRe:=NewRe;
    FPolarValid:=False;
  end;

procedure TComplex.SetIm;
  begin
    if not FRectValid then CalcRect;
    FIm:=NewIm;
    FPolarValid:=False;
  end;

procedure TComplex.SetR;
  begin
    if not FPolarValid then CalcPolar;
    FR:=NewR;
    FRectValid:=False;
  end;

procedure TComplex.SetArg;
  begin
    if not FPolarValid then CalcPolar;
    FArg:=NewArg;
    FRectValid:=False;
  end;



{------------------------------------------------------------------------------------}
{ String conversions                                                                 }
{------------------------------------------------------------------------------------}

{ The format string can contain the following tags, at any position and any number }
{ of times:                                                                        }
{   %%   Percent sign                                                              }
{   %r   Real part                                                                 }
{   %i   Imaginary part                                                            }
{   %R   Radius                                                                    }
{   %A   Argument in degrees                                                       }
{   %a   Argument in radians                                                       }
{ The Width and Dec arguments currently apply equally to all tags.                 }
function TComplex.FormatStr;
  var
    p : Integer;
    c : Char;
    s : string;
  begin
    Result:=Format;
    p:=1;
    while p<Length(Result) do begin     { Strict < because all tags are 2 chars long }
      if Result[p]='%' then begin
        c:=Result[p+1];
        if c='%' then begin
          Delete(Result,p,1)
        end
        else if c in ['r','i','R','A','a'] then begin
          Delete(Result,p,2);
          { In the Str calls, use properties to get automatic rect<->polar }
          { conversion whenever needed. }
          case c of
            'r': Str(Re        :Width:Dec,s);
            'i': Str(Im        :Width:Dec,s);
            'R': Str(R         :Width:Dec,s);
            'A': Str(Arg/Pi*180:Width:Dec,s);
            'a': Str(Arg       :Width:Dec,s);
          end;
          Insert(s,Result,p);
          Inc(p,Length(s)-1);
        end;
      end;
      Inc(p);
    end;
  end;

{ The first encountered tag determines if rectangular or polar input is assumed. If }
{ the matching tag is missing, it is assumed to be zero. E.g. if %A is found, but   }
{ not %R, then the radius is assumed zero. (In this case, the argument is really    }
{ undefined mathematically speaking, but the input value is retained.               }
procedure TComplex.FormatVal;
  var
    pf : Integer;                  { Char position of next padding in Format }
    ps : Integer;                  { Char position of next padding in s }
    ptag : Integer;                { Char position of next tag in Format }
    pnum : Integer;                { Char position of number in s }
    x : CReal;                     { Temporary for converted number }
    tag : Char;                    { The tag character for next conversion }
    f : string;                    { Working copy of Format }
    FoundTag : Boolean;            { Set to True in tag search loop when tag found }
  begin
    { Invalidate both rect and polar values. The first tag encountered determines }
    { which of these will be enabled.                                             }
    FRectValid:=False;
    FPolarValid:=False;
    { Reset all values so that those not present in s/Format are set to zero. }
    FRe:=0;
    FIm:=0;
    FR:=0;
    FArg:=0;
    { Do the conversion. }
    f:=Format;
    pf:=1;                { First padding at start of string }
    pnum:=0;              { Haven't found our first number yet }
    while pnum<=Length(s) do begin
      { Scan for next tag in f. After the loop, ptag will point at the '%' of }
      { the tag. If no tag is found, ptag points one char past the end of the      }
      { string.                                                                    }
      ptag:=pf;
      FoundTag:=False;
      while (ptag<=Length(f)) and not FoundTag do begin
        { Check for a '%'. }
        if f[ptag]='%' then begin
          { Found '%', check if it is at the end of f. }
          if ptag+1<=Length(f) then begin
            { Found '%' not at end of f, check if it is a '%%'. }
            if  f[ptag+1]='%' then begin
              { Found '%%', change it to '%' so it compares correctly with s. }
              Delete(f,ptag,1);
              Inc(ptag);
            end
            else begin
              { Found a number tag, check if it is valid. }
              if FRectValid  and (f[ptag+1] in ['R','A','a'])
              or FPolarValid and (f[ptag+1] in ['r','i'    ])
              then raise Exception.Create('Complex val: Invalid format'
                                         +' (mixed rect and polar).');
              if not (f[ptag+1] in ['r','i','R','A','a'])
              then raise Exception.Create('Complex val: Invalid format'
                                         +' (invalid tag).');
              FoundTag:=True;
            end;
          end
          else begin
            { Found '%' at end of f, treat it as a normal character. }
            Inc(ptag);
          end;
        end
        else begin
          { No '%' yet, go to next pos. }
          Inc(ptag);
        end;
      end;
      { Find the matching padding substring in s. }
      if      pf>Length(f) then ps:=Length(s)+1
      else if ptag=1       then ps:=1
                           else ps:=ps-1+Pos(Copy(f,pf,ptag-pf),Copy(s,ps,Length(s)));
      if ps<=pnum
      then raise Exception.Create('Complex val: String does not match format.');
      { If pnum points to start of a number and ps to start of next padding, convert }
      { the pointed-out number. }
      if pnum>0 then begin
        x:=StrToFloat(Copy(s,pnum,ps-pnum));
        case tag of
          'r': begin FRe :=x       ; FRectValid :=True; end;
          'i': begin FIm :=x       ; FRectValid :=True; end;
          'R': begin FR  :=x       ; FPolarValid:=True; end;
          'A': begin FArg:=x/180*Pi; FPolarValid:=True; end;
          'a': begin FArg:=x       ; FPolarValid:=True; end;
        end;
      end;
      { Mark the number found this round, and remember its tag character. }
      pnum:=ps+ptag-pf;
      if ptag<Length(f) then tag:=f[ptag+1];
      { Prepare for next round. }
      pf:=ptag+2;                                { All tags are two characters long. }
      ps:=pnum;
    end;
    { Normalize argument to interval [-Pi,Pi). }
    if FPolarValid then begin
      while FArg <  -Pi do FArg:=FArg+Pi2;
      while FArg >= +Pi do FArg:=FArg-Pi2;
    end;
  end;



{------------------------------------------------------------------------------------}
{ Assignment                                                                         }
{------------------------------------------------------------------------------------}

procedure TComplex.Assign;
  begin
    FRectValid:=z.FRectValid;
    if FRectValid then begin
      FRe:=z.FRe;
      FIm:=z.FIm;
    end;
    FPolarValid:=z.FPolarValid;
    if FPolarValid then begin
      FR:=z.FR;
      FArg:=z.FArg;
    end;
  end;



{------------------------------------------------------------------------------------}
{ Comparison                                                                         }
{------------------------------------------------------------------------------------}

{ The comparisons should really allow a small }
{ tolerance, but that's for next version...   }
function TComplex.Equals;
  begin
    if FRectValid and z.FRectValid then
      Result:=(FRe=z.FRe) and (FIm=z.FIm)      { Compare existing rect parts }
    else if FPolarValid and z.FPolarValid then
      Result:=(FR=z.FR) and (FArg=z.FArg)      { Compare existing polar parts }
    else
      Result:=(Re=z.Re) and (Im=z.Im);         { Force rect parts and compare them }
  end;

{ The comparisons should really allow a small }
{ tolerance, but that's for next version...   }
function TComplex.Differs;
  begin
    if FRectValid and z.FRectValid then
      Result:=(FRe<>z.FRe) or (FIm<>z.FIm)      { Compare existing rect parts }
    else if FPolarValid and z.FPolarValid then
      Result:=(FR<>z.FR) and (FArg<>z.FArg)      { Compare existing polar parts }
    else
      Result:=(Re<>z.Re) and (Im<>z.Im);         { Force rect parts and compare them }
  end;



{------------------------------------------------------------------------------------}
{ Basic complex operations                                                           }
{------------------------------------------------------------------------------------}

procedure TComplex.Negate;
  begin
    if FRectValid then begin
      FRe:=-FRe;
      FIm:=-FIm;
    end;
    if FPolarValid then begin
      if FArg>=0 then FArg:=FArg-Pi
                 else FArg:=FArg+Pi;
    end;
  end;

{ Change sign of Im and/or sign of Arg. If Arg is -Pi it is not }
{ changed, in order to keep it within the interval [-Pi,Pi).    }
procedure TComplex.Conjugate;
  begin
    if FRectValid then FIm:=-FIm;
    if FpolarValid and (FArg<>-Pi) then FArg:=-FArg;
  end;

procedure TComplex.Add;
  begin
    if not FRectValid then CalcRect;
    FRe := FRe + z.Re;
    FIm := FIm + z.Im;
  end;

procedure TComplex.Subtract;
  begin
    if not FRectValid then CalcRect;
    FRe := FRe - z.Re;
    FIm := FIm - z.Im;
  end;

procedure TComplex.Multiply;
  var
    Tmp : CReal;
  begin
    if FPolarValid then begin
      { Polar: One multiplication and two to four additive operations. }
      FR := FR * z.R;
      FArg := FArg + z.Arg;
      if      FArg <  -Pi then FArg:=FArg+Pi2
      else if FArg >= +Pi then FArg:=FArg-Pi2;
    end
    else begin
      { Rect: Four multiplications and two additive operations. }
      Tmp := FRe * z.Re - FIm * z.Im;
      FIm := FRe * z.Im + FIm * z.Re;
      FRe := Tmp;
    end;
  end;

procedure TComplex.Divide;
  var
    Divisor : CReal;
    Tmp     : CReal;
  begin
    if FPolarValid then begin
      { Polar: One division and two to four additive operations. }
      FR := FR / z.R;
      FArg := FArg - z.Arg;
      if      FArg <  -Pi then FArg:=FArg+Pi2
      else if FArg >= +Pi then FArg:=FArg-Pi2;
    end
    else begin
      { Rect: Two divisions, six multiplications and three additive operations. }
      Divisor := System.Sqr(z.Re) + System.Sqr(z.Im);
      Tmp := (FRe * z.Re + FIm * z.Im) / Divisor;
      FIm := (FIm * z.Re - FRe * z.Im) / Divisor;
      FRe := Tmp;
    end;
  end;

procedure TComplex.Invert;
  var
    Divisor : CReal;
  begin
    if FPolarValid then begin
      { Polar: One division and two or three additive operations. }
      FR := 1 / FR;
      FArg := -FArg;
      if      FArg <  -Pi then FArg:=FArg+Pi2
      else if FArg >= +Pi then FArg:=FArg-Pi2;
    end
    else begin
      { Rect: Two divitions, two multiplications and two additive operations. }
      Divisor := System.Sqr(FRe) + System.Sqr(FIm);
      FRe :=  FRe / Divisor;
      FIm := -FIm / Divisor;
    end;
  end;

procedure TComplex.Sqr;
  var
    Tmp : CReal;
  begin
    if FPolarValid then begin
      { Polar: One multiplication and two to four additive operations. }
      FR := System.Sqr(FR);
      FArg := FArg + FArg;
      if      FArg <  -Pi then FArg:=FArg+Pi2
      else if FArg >= +Pi then FArg:=FArg-Pi2;
    end
    else begin
      { Rect: Four multiplications and one additive operation. }
      Tmp := System.Sqr(FRe) - System.Sqr(FIm);
      FIm := 2 * FRe * FIm;
      FRe := Tmp;
    end;
  end;

procedure TComplex.Sqrt;
  begin
    if not FPolarValid then CalcPolar;
    FR := System.Sqrt(FR);
    FArg := FArg / 2;
  end;



{------------------------------------------------------------------------------------}
{ Logarithms and exponentials                                                        }
{------------------------------------------------------------------------------------}

procedure TComplex.Ln;
  begin
    if not FPolarValid then CalcPolar;
    FRe := System.Ln(FR);
    FIm := FArg;
    FRectValid :=True ;
    FPolarValid:=False;
  end;

procedure TComplex.Exp;
  begin
    if not FRectValid then CalcRect;
    FR := System.Exp(FRe);
    FArg := FIm;
    if      FArg <  -Pi then FArg:=FArg+Pi2
    else if FArg >= +Pi then FArg:=FArg-Pi2;
    FRectValid :=False;
    FPolarValid:=True ;
  end;

procedure TComplex.Log;
  begin
    Ln;
    Divide(CLn(a));
  end;

procedure TComplex.Power;
  begin
    Multiply(CLn(a));
    Exp;
  end;



{------------------------------------------------------------------------------------}
{ Trigonometrics                                                                     }
{------------------------------------------------------------------------------------}

procedure TComplex.Sin;
  var
    Tmp : CReal;
  begin
    if not FRectValid then CalcRect;
    Tmp := System.Sin(FRe) * ( System.Exp(FIm) + System.Exp(-FIm) ) / 2;
    FIm := System.Cos(FRe) * ( System.Exp(FIm) - System.Exp(-FIm) ) / 2;
    FRe := Tmp;
  end;

procedure TComplex.Cos;
  var
    Tmp : CReal;
  begin
    if not FRectValid then CalcRect;
    Tmp := System.Cos(FRe) * ( System.Exp(-FIm) + System.Exp(FIm) ) / 2;
    FIm := System.Sin(FRe) * ( System.Exp(-FIm) - System.Exp(FIm) ) / 2;
    FRe := Tmp;
  end;

procedure TComplex.Tan;
  var
    Tmp : TComplex;
  begin
    Tmp:=CCos(self);
    Sin;
    Divide(Tmp);
  end;

procedure TComplex.Cotan;
  var
    Tmp : TComplex;
  begin
    Tmp:=CSin(self);
    Cos;
    Divide(Tmp);
  end;



{------------------------------------------------------------------------------------}
{ Inverse trigonometrics                                                             }
{------------------------------------------------------------------------------------}

{ ArcSin(z) = -iLn(iz+Sqrt(1-z^2)) }
procedure TComplex.ArcSin;
  begin
    Assign(   CAdd(  CMul(self,Ci)  ,  CSqrt( CSub(COne,CSqr(self)) )  )   );
    Ln;
    Multiply(CMinusi);
  end;

{ ArcCos(z) = -iLn(z+Sqrt(z^2-1)) }
procedure TComplex.ArcCos;
  begin
    Assign(   CAdd(       self            ,  CSqrt( CSub(CSqr(self),COne) )  )   );
    Ln;
    Multiply(CMinusi);
  end;

{ ArcTan(z) = -i/2 * Ln((1+iz)/(1-iz)) }
procedure TComplex.ArcTan;
  var
    Tmp : TComplex;
  begin
    Multiply(Ci);
    Assign(  CDiv( CAdd(COne,self) , CSub(COne,self) )  );
    Ln;
    Multiply(TComplex.CreateRect(0,-0.5));
  end;

{ ArcCotan(z) = -i/2 * Ln((z+i)/(z-i)) }
procedure TComplex.ArcCotan;
  begin
    Assign(  CDiv( CAdd(self,Ci) , CSub(self,Ci) )  );
    Ln;
    Multiply(TComplex.CreateRect(0,-0.5));
  end;



{------------------------------------------------------------------------------------}
{ Hyperbolics                                                                        }
{------------------------------------------------------------------------------------}

procedure TComplex.Sinh;
  var
    Tmp : CReal;
  begin
    if not FRectValid then CalcRect;
    Tmp := System.Cos(FIm) * ( System.Exp(FRe) - System.Exp(-FRe) ) / 2;
    FIm := System.Sin(FIm) * ( System.Exp(FRe) + System.Exp(-FRe) ) / 2;
    FRe := Tmp;
  end;

procedure TComplex.Cosh;
  var
    Tmp : CReal;
  begin
    if not FRectValid then CalcRect;
    Tmp := System.Cos(FIm) * ( System.Exp(FRe) + System.Exp(-FRe) ) / 2;
    FIm := System.Sin(FIm) * ( System.Exp(FRe) - System.Exp(-FRe) ) / 2;
    FRe := Tmp;
  end;

{ Tanh(z) = Sinh(z) / Cosh(z) }
procedure TComplex.Tanh;
  var
    Tmp : TComplex;
  begin
    Tmp:=CCosh(self);
    Sinh;
    Divide(Tmp);
  end;

{ Cotanh(z) = Cosh(z) / Sinh(z) }
procedure TComplex.Cotanh;
  var
    Tmp : TComplex;
  begin
    Tmp:=CSinh(self);
    Cosh;
    Divide(Tmp);
  end;



{------------------------------------------------------------------------------------}
{ Inverse hyperbolics                                                                }
{------------------------------------------------------------------------------------}

{ ArcSinh(z) = Ln( z + Sqrt(z^2 + 1) ) }
procedure TComplex.ArcSinh;
  begin
    Assign(  CAdd( self , CSqrt( CAdd(CSqr(self),COne) ) )  );
    Ln;
  end;

{ ArcCosh(z) = Ln( z + Sqrt(z^2 - 1) ) }
procedure TComplex.ArcCosh;
  begin
    Assign(  CAdd( self , CSqrt( CSub(CSqr(self),COne) ) )  );
    Ln;
  end;

{ ArcTanh(z) = Ln( (1+z)/(1-z) ) / 2 }
procedure TComplex.ArcTanh;
  begin
    Assign(  CDiv( CAdd(COne,self) , CSub(COne,self) )  );
    Ln;
    Divide(TComplex.CreateRect(2,0));
  end;

{ ArcCotanh(z) = Ln( (z+1)/(z-1) ) / 2 }
procedure TComplex.ArcCotanh;
  begin
    Assign(  CDiv( CAdd(self,COne) , CSub(self,COne) )  );
    Ln;
    Divide(TComplex.CreateRect(2,0));
  end;



{------------------------------------------------------------------------------------}
{ Standalone functions                                                               }
{------------------------------------------------------------------------------------}

function StrToComplexF;
  begin
    Result:=TComplex.Create;
    Result.FormatVal(s,Format);
  end;

function CEq(x,y:TComplex) : Boolean;
  begin
    Result:=x.Equals(y);
  end;

function CDiff(x,y:TComplex) : Boolean;
  begin
    Result:=x.Differs(y);
  end;

function CNeg;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Negate;
  end;

function CConj;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Conjugate;
  end;

function CAdd;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Add(y);
  end;

function CSub;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Subtract(y);
  end;

function CMul;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Multiply(y);
  end;

function CDiv;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Divide(y);
  end;

function CInv;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Invert;
  end;

function CSqr;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Sqr;
  end;

function CSqrt;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Sqrt;
  end;

function CLn;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Ln;
  end;

function CExp;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Exp;
  end;

function CLog;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Log(a);
  end;

function CPow;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Power(a);
  end;

function CSin;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Sin;
  end;

function CCos;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Cos;
  end;

function CTan;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Tan;
  end;

function CCotan;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Cotan;
  end;

function CArcSin;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcSin;
  end;

function CArcCos;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcCos;
  end;

function CArcTan;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcTan;
  end;

function CArcCotan;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcCotan;
  end;

function CSinh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Sinh;
  end;

function CCosh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Cosh;
  end;

function CTanh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Tanh;
  end;

function CCotanh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.Cotanh;
  end;

function CArcSinh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcSinh;
  end;

function CArcCosh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcCosh;
  end;

function CArcTanh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcTanh;
  end;

function CArcCotanh;
  begin
    Result:=TComplex.CreateComplex(x);
    Result.ArcCotanh;
  end;



initialization
  COne      := TComplex.CreateRect( 1, 0);
  CMinusOne := TComplex.CreateRect(-1, 0);
  Ci        := TComplex.CreateRect( 0, 1);
  CMinusi   := TComplex.CreateRect( 0,-1);
end.
