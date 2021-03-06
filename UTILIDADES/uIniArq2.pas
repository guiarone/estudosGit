unit uIniArq2;

interface

uses
//XE2
//  WinTypes, Classes, Dialogs;
//XE
  {WinTypes, }Classes, Dialogs;

type
  TIniArq = class (TObject)
  private
    _NomeArq: PChar;
    function _GetNomeArq: string;
  public
    constructor Create(const aNomeArq: string);
    destructor  Destroy; override;
    procedure   ApagaItem(const Secao, Item: string);
    procedure   ApagaSecao(const Secao: string);
    procedure   GravaBool(const Secao, Item: string; Conteudo: Boolean);
    procedure   GravaFloat(const Secao, Item: string; Conteudo: Double);
    procedure   GravaHexa(const Secao, Item: string; Conteudo: Longint; Dig: byte);
    procedure   GravaInteiro(const Secao, Item: string; Conteudo: Longint);
    procedure   GravaString(const Secao, Item, Conteudo: string);
    procedure   GravaSubItens(const Secao, Item: string; Strings: TStrings);
    function    ItemPos(const Secao: string; Pos: integer): string;
    function    LeBool(const Secao, Item: string; oDefault: Boolean): Boolean;
    procedure   LeConteudosDaSecao(const Secao: string; Strings: TStrings);
    procedure   LeConteudosDaSecaoMasc(const Secao, Masc: string; Strings: TStrings);
    function    LeFloat(const Secao, Item: string; oDefault: Double): Double;
    function    LeHexa(const Secao, Item: string; oDefault: Longint): LongInt;
    function    LeInteiro(const Secao, Item: string; oDefault: Longint): LongInt;
    function    LeQtItensSecao(const Secao: string): Integer;
    procedure   LeSecao(const Secao: string; Strings: TStrings);
    procedure   LeSecaoInteira(const Secao: string; Strings: TStrings);
    procedure   LeSecaoMasc(const Secao, Masc: string; Strings: TStrings);
    function    LeString(const Secao, Item, oDefault: string): string;
    procedure   LeSubItens(const Secao, Item: string; Strings: TStrings);
    procedure   LeTodasAsSecoesDoArquivo(Strings: TStrings);
    function    PosItem(const Secao, Item: string): Integer;
  end;
  
implementation

uses
//XE2
//  WinProcs, SysUtils, Consts, Windows;
//XE
  {WinProcs, }SysUtils, Consts, Windows;

{
*********************************** TIniArq ************************************
}
constructor TIniArq.Create(const aNomeArq: string);
begin
  inherited Create;
  _NomeArq:= StrPCopy( StrAlloc( Succ( Length( aNomeArq ) ) ), aNomeArq );
end;

destructor TIniArq.Destroy;
begin
  StrDispose( _NomeArq );
  inherited Destroy;
end;

procedure TIniArq.ApagaItem(const Secao, Item: string);
var
  cSecao: array[0..127] of ansiChar;
  cItem : array[0..127] of ansiChar;
  Apagou: Boolean;
begin
  Apagou:= WritePrivateProfileString(
             StrPLCopy( cSecao, Secao, SizeOf( cSecao ) - 1 ),
             StrPLCopy( cItem, Item, SizeOf( cItem ) - 1 ),
             nil,
             _NomeArq
           );
  
  if not Apagou then
  begin
    ShowMessage( 'Erro ao apagar item "' + UpperCase( Item ) +
                 '" da se??o [' + UpperCase( Secao ) +
                 '] no arquivo ' + _GetNomeArq + ' !');
  end;
end;

procedure TIniArq.ApagaSecao(const Secao: string);
var
  cSecao: array[0..127] of Char;
  Apagou: Boolean;
begin
  Apagou:= WritePrivateProfileString(
             StrPLCopy( cSecao, Secao, SizeOf( cSecao ) - 1 ),
             nil,
             nil,
             _NomeArq
           );
  if not Apagou then
  begin
    ShowMessage( 'Erro ao apagar se??o [' + UpperCase( Secao ) +
                 '] no arquivo ' + _GetNomeArq + ' !');
  end;
end;

procedure TIniArq.GravaBool(const Secao, Item: string; Conteudo: Boolean);
  
  const
    LConteudo: array[Boolean] of string[1] = ('0', '1');
  
begin
  GravaString( Secao, Item, LConteudo[Conteudo] );
end;

procedure TIniArq.GravaFloat(const Secao, Item: string; Conteudo: Double);
var
  oAnt: Char;
begin
  oAnt:= DecimalSeparator; // guarda indicador de casas decimais
  DecimalSeparator:= ',';  // muda indicador de casa decimal para v?rgula
  GravaString( Secao, Item, FloatToStr( Conteudo ) );
  DecimalSeparator:= oAnt; // restaura indicador de casas decimais
end;

procedure TIniArq.GravaHexa(const Secao, Item: string; Conteudo: Longint; Dig: 
        byte);
begin
  GravaString( Secao, Item, IntToHex( Conteudo, Dig ) );
end;

procedure TIniArq.GravaInteiro(const Secao, Item: string; Conteudo: Longint);
begin
  GravaString( Secao, Item, IntToStr( Conteudo ) );
end;

procedure TIniArq.GravaString(const Secao, Item, Conteudo: string);
var
  cSecao: array[0..127] of Char;
  cItem: array[0..127] of Char;
  cConteudo: array[0..255] of Char;
  Gravou: Boolean;
begin
//  if length(conteudo) > 0 then
    Gravou:= WritePrivateProfileString(
             StrPLCopy( cSecao, Secao, SizeOf( cSecao ) - 1),
             StrPLCopy( cItem, Item, SizeOf( cItem ) - 1),
             StrPCopy( cConteudo, Conteudo ),
             _NomeArq
           );
  (*else
    Gravou:= WritePrivateProfileString(
             StrPLCopy( cSecao, Secao, SizeOf( cSecao ) - 1),
             StrPLCopy( cItem, Item, SizeOf( cItem ) - 1),
             nil,
             _NomeArq
           );
    *)
  if not Gravou then
  begin
    ShowMessage( 'Erro ao gravar item "' + UpperCase( Item ) +
                 '" da se??o [' + UpperCase( Secao ) +
                 '] no arquivo ' + _GetNomeArq + ' !');
  end;
end;

procedure TIniArq.GravaSubItens(const Secao, Item: string; Strings: TStrings);
  
  const
    BufSize = 8192;
  var
    Buffer, P: PChar;
    Cont: integer;
    CSecao: array[0..127] of Char;
    CItem: array[0..127] of Char;
    CConteudo: array[0..255] of Char;
    Gravou : Boolean;
  
begin
  GetMem( Buffer, BufSize );
  try
    P:= Buffer;
    StrPCopy( P, Strings.Strings[0] );
    for Cont:= 1 to Pred( Strings.Count ) do
    begin
      StrPCopy( CConteudo, Strings.Strings[Cont] );
      StrCat( P, ';' );
      StrCat( P, CConteudo );
    end;
    Gravou:= WritePrivateProfileString(
               StrPLCopy( CSecao, Secao, Pred( SizeOf( CSecao ) ) ),
               StrPLCopy( CItem, Item, Pred( SizeOf( CItem ) ) ),
               P,
               _NomeArq
             );
  
    if not Gravou then
    begin
      ShowMessage( 'Erro ao gravar subitens da se??o [' + UpperCase( Secao ) +
                   '] no arquivo ' + _GetNomeArq + ' !' );
    end;
  finally
    FreeMem( Buffer, BufSize );
  end;
end;

function TIniArq.ItemPos(const Secao: string; Pos: integer): string;
var
  Strings: TStringList;
begin
  Result:= '';
  Strings:= TStringList.Create;
  LeSecao( Secao, Strings );
  if ( Pos < Strings.Count ) then
    Result:= Strings.Strings[Pos];
  Strings.Free;
end;

function TIniArq.LeBool(const Secao, Item: string; oDefault: Boolean): Boolean;
begin
  Result:= LeInteiro( Secao, Item, Ord(oDefault) ) <> 0;
end;

procedure TIniArq.LeConteudosDaSecao(const Secao: string; Strings: TStrings);
var
  KeyList: TStringList;
  I: Integer;
begin
  KeyList:= TStringList.Create;
  try
    Strings.Clear;
    LeSecao( Secao, KeyList );
    for I := 0 to Pred( Keylist.Count ) do
      Strings.Add( LeString( Secao, KeyList[I], '' ) );
  finally
    KeyList.Free;
  end;
end;

procedure TIniArq.LeConteudosDaSecaoMasc(const Secao, Masc: string; Strings: 
        TStrings);
var
  KeyList: TStringList;
  I: Integer;
begin
  KeyList:= TStringList.Create;
  try
    Strings.Clear;
    LeSecaoMasc( Secao, Masc, KeyList );
    for I := 0 to Pred( Keylist.Count ) do
      Strings.Add( LeString( Secao, KeyList[I], '' ) );
  finally
    KeyList.Free;
  end;
end;

function TIniArq.LeFloat(const Secao, Item: string; oDefault: Double): Double;
var
  IStr: string;
  oAnt: Char;
begin
  oAnt:= DecimalSeparator; // guarda indicador de casas decimais
  IStr:= LeString( Secao, Item, '' );
  try
    // tenta converter com a virgula como indicador decimal
    DecimalSeparator:= ',';
    Result:= StrToFloatDef( IStr,0 );
  except
    try
      // se nao converteu com a virgula , tenta com o ponto
      DecimalSeparator:= '.';
      Result := StrToFloatDef( IStr,0 );
    except
      // erro fatal na conversao , usa o valor default
      ShowMessage( 'O item "' + UpperCase( Item ) +
                   '" da se??o [' + UpperCase( Secao ) +
                   '] do arquivo ' + _GetNomeArq + ' n?o ? v?lido!' );
      ShowMessage( 'Usando o valor default ( ' + FloatToStr( oDefault ) + ' ) !' );
      Result:= oDefault;
    end;
  end;
  DecimalSeparator:= oAnt; // restaura indicador de casas decimais
end;

function TIniArq.LeHexa(const Secao, Item: string; oDefault: Longint): LongInt;
var
  IStr: string;
begin
  IStr:= '$' + LeString( Secao, Item, '' );
  Result:= StrToIntDef( IStr, oDefault );
end;

function TIniArq.LeInteiro(const Secao, Item: string; oDefault: Longint): 
        LongInt;
var
  IStr: string;
begin
  IStr:= LeString( Secao, Item, '' );
  if ( CompareText( Copy( IStr, 1, 2 ), '0x' ) = 0 ) then
    IStr:= '$' + Copy( IStr, 3, 255 );
  Result:= StrToIntDef( IStr, oDefault );
end;

function TIniArq.LeQtItensSecao(const Secao: string): Integer;
var
  Strings: TStringList;
begin
  Strings:= TStringList.Create;
  LeSecao( Secao, Strings );
  Result:= Strings.Count;
  Strings.Free;
end;

procedure TIniArq.LeSecao(const Secao: string; Strings: TStrings);
  
  const
//    BufSize = 8192;
    BufSize = 16384;
  var
    Buffer, P: PChar;
    Count: Integer;
    cSecao: array[0..127] of Char;
  
begin
  GetMem( Buffer, BufSize );
  try
    Strings.Clear;
    Count:= GetPrivateProfileString(
              StrPLCopy( cSecao, Secao, SizeOf( cSecao ) - 1 ),
              nil,
              nil,
              Buffer,
              BufSize,
              _NomeArq
            );
  
    P:= Buffer;
    if ( Count > 0 )then
    begin
      while ( P[0] <> #0 ) do
      begin
        Strings.Add( StrPas( P ) );
        Inc( P, Succ( StrLen( P ) ) );
      end;
    end;
  finally
    FreeMem( Buffer, BufSize );
  end;
end;

procedure TIniArq.LeSecaoInteira(const Secao: string; Strings: TStrings);
var
  KeyList: TStringList;
  I: Integer;
begin
  KeyList:= TStringList.Create;
  try
    Strings.Clear;
    LeSecao( Secao, KeyList );
    for I := 0 to Pred( Keylist.Count ) do
      Strings.Add( KeyList[I] + '=' + LeString( Secao, KeyList[I], '' ) );
  finally
    KeyList.Free;
  end;
end;

procedure TIniArq.LeSecaoMasc(const Secao, Masc: string; Strings: TStrings);
  
    function Compara( S1, S2: string ): boolean;
    var
      Tam, Cont: byte;
    begin
      Tam:= Length( S2 ); {tam da 2a string}
  
      if ( Tam > Length( S1 ) ) then          {compara at? o menor tamanho}
        Tam:= Length( S1 );
  
      if ( Tam <> 0 ) then
      begin
        Result:= true;
        for cont:= 1 to Tam do
          if ( S1[Cont] <> S2[Cont] ) then
            Result:= false;
      end
      else
        Result:= false;
    end; {### function Compara ###}
  const
    BufSize = 8192;
  var
    Buffer, P: PChar;
    Count: Integer;
    CSecao: array[0..127] of Char;
  
begin
  GetMem( Buffer, BufSize );
  try
    Strings.Clear;
    Count:= GetPrivateProfileString(
              StrPLCopy( CSecao, Secao, Pred( SizeOf( CSecao ) ) ),
              nil,
              nil,
              Buffer,
              BufSize,
              _NomeArq
            );
    P:= Buffer;
    if ( Count > 0 ) then
      while ( P[0] <> #0 ) do
      begin
        if Compara( StrPas( P ), Masc ) then
          Strings.Add( StrPas( P ) );
        Inc( P, Succ( StrLen( P ) ) );
      end;
  finally
    FreeMem( Buffer, BufSize );
  end;
end;

function TIniArq.LeString(const Secao, Item, oDefault: string): string;
var
  cSecao: array[0..127] of Char;
  cItem: array[0..127] of Char;
  cDefault: array[0..255] of Char;
  Retorno: array[0..255] of Char;
begin
  GetPrivateProfileString(
    StrPLCopy( cSecao, Secao, SizeOf( cSecao ) - 1 ),
    StrPLCopy( cItem, Item, SizeOf( cItem ) - 1 ),
    StrPCopy( cDefault, oDefault ),
    Retorno,
    256,
    _NomeArq
  );
  
  Result:= StrPas( Retorno );
end;

procedure TIniArq.LeSubItens(const Secao, Item: string; Strings: TStrings);
  
  const
    BufSize = 8192;
  var
    Buffer, P: PChar;
    SubItem: string;
    Posicao, Count, T: Integer;
    cSecao: array[0..127] of Char;
    cItem: array[0..127] of Char;
  
begin
  GetMem( Buffer, BufSize );
  try
    Strings.Clear;
    Count:= GetPrivateProfileString(
              StrPLCopy( cSecao, Secao, Pred( SizeOf(cSecao) ) ),
              StrPLCopy( cItem, Item, Pred( SizeOf(cItem) ) ),
              nil,
              Buffer,
              BufSize,
              _NomeArq
            );
    P := Buffer;
    if ( Count > 0 ) then
    begin
      Posicao:= 0;
      T:= StrLen( P );
      while ( Posicao < T ) do
      begin
        SubItem:= '';
        while ( P[Posicao] <> ';' ) and ( Posicao < T ) do
        begin
          SubItem:= SubItem + P[Posicao];
          Inc( Posicao );
        end;
        Inc( Posicao );
        Strings.Add( SubItem );
      end;
    end;
  finally
    FreeMem( Buffer, BufSize );
  end;
end;

procedure TIniArq.LeTodasAsSecoesDoArquivo(Strings: TStrings);
  
  const
    BufSize = 8192;
  var
    Buffer, P: PChar;
    Count: Integer;
  
begin
  GetMem( Buffer, BufSize );
  try
    Strings.Clear;
    Count:= GetPrivateProfileSectionNames(
              Buffer,
              BufSize,
              _NomeArq
            );
  
    P:= Buffer;
    if ( Count > 0 )then
    begin
      while ( P[0] <> #0 ) do
      begin
        Strings.Add( StrPas( P ) );
        Inc( P, Succ( StrLen( P ) ) );
      end;
    end;
  finally
    FreeMem( Buffer, BufSize );
  end;
end;

function TIniArq.PosItem(const Secao, Item: string): Integer;
var
  Strings: TStringList;
  cont: Integer;
begin
  Result:= -1;
  Strings:= TStringList.Create;
  LeSecao( Secao, Strings );
  for cont:= 0 to Pred(Strings.Count) do
    if ( Strings.Strings[Cont] = Item ) then
    begin
      Result:= Cont;
      Break;
    end;
  Strings.Free;
end;

function TIniArq._GetNomeArq: string;
begin
  Result:= ExtractFileName( StrPas( _NomeArq ) );
end;

end.
