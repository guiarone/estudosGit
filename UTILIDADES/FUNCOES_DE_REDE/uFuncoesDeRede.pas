unit uFuncoesDeRede;

interface

uses
  IpHlpApi, Winapi.IpRtrMib , Winapi.Windows, System.Classes, Winapi.IpTypes, sysutils;


const
  MIB_IF_OPER_STATUS_NON_OPERATIONAL = 0;
  MIB_IF_OPER_STATUS_UNREACHABLE = 1;
  MIB_IF_OPER_STATUS_DISCONNECTED = 2;
  MIB_IF_OPER_STATUS_CONNECTING  = 3;
  MIB_IF_OPER_STATUS_CONNECTED   = 4;
  MIB_IF_OPER_STATUS_OPERATIONAL = 5;

  MIB_IF_TYPE_OTHER    = 1;
  MIB_IF_TYPE_ETHERNET = 6;
  MIB_IF_TYPE_TOKENRING = 9;
  MIB_IF_TYPE_FDDI     = 15;
  MIB_IF_TYPE_PPP      = 23;
  MIB_IF_TYPE_LOOPBACK = 24;
  MIB_IF_TYPE_SLIP     = 28;

  MIB_IF_ADMIN_STATUS_UP      = 1;
  MIB_IF_ADMIN_STATUS_DOWN    = 2;
  MIB_IF_ADMIN_STATUS_TESTING = 3;

  ANY_SIZE      = 1;

  function ListaMacAdress(var Nomes, MACs, IPs, Mascaras: TStringList): boolean;//tentativa 1
  procedure Get_IPAddrTable(Tipo: Integer; List: TStrings );

implementation

{ converts IP-address in network byte order DWORD to dotted decimal string}
function IpAddr2Str( IPAddr: DWORD ): string;
var
  i : integer;
begin
  Result := '';
  for i := 1 to 4 do
  begin
    Result := Result + Format( '%3d.', [IPAddr and $FF] );
    IPAddr := IPAddr shr 8;
  end;
  Delete( Result, Length( Result ), 1 );
end;

procedure Get_IPAddrTable(Tipo: Integer; List: TStrings );
var
  IPAddrRow     : MIB_IPADDRROW;
  TableSize     : DWORD;
  ErrorCode     : DWORD;
  i             : integer;
  pBuf          : PAnsiChar;
  NumEntries    : DWORD;
  auxS          : string;
begin
  if not Assigned( List ) then EXIT;
  List.Clear;
  TableSize := 0; ;
  // first call: get table length
  ErrorCode := GetIpAddrTable( PMIB_IPADDRTABLE( pBuf ), TableSize, true );
  if Errorcode <> ERROR_INSUFFICIENT_BUFFER then
    EXIT;

  GetMem( pBuf, TableSize );
  // get table
  ErrorCode := GetIpAddrTable( PMIB_IPADDRTABLE( pBuf ), TableSize, true );
  if ErrorCode = NO_ERROR then
  begin
    NumEntries := PMIB_IPADDRTABLE( pBuf )^.dwNumEntries;
    if NumEntries > 0 then
    begin
      inc( pBuf, SizeOf( DWORD ) );
      for i := 1 to NumEntries do
      begin
        Case Tipo of
        1 : begin
             IPAddrRow := PMIB_IPADDRROW( pBuf )^;
             with IPAddrRow do
             begin
               auxS:= 'IP: '+IPAddr2Str( dwAddr )+', MASC: '+IPAddr2Str( dwMask );
               List.Add(auxS);
               //List.Add( Format( '%8.8x|%15s|%15s|%15s|%8.8d',
               //          [dwIndex, IPAddr2Str( dwAddr ), IPAddr2Str( dwMask ),
               //          IPAddr2Str( dwBCastAddr ), dwReasmSize ] ) );
             end;
             inc( pBuf, SizeOf( TMIBIPAddrRow ) );
            end;
        2 : begin
             IPAddrRow := PMIB_IPADDRROW( pBuf )^;
             List.Add( Format('%15s',[IPAddr2Str(IPAddrRow.dwAddr)]) );
             inc( pBuf, SizeOf( TMIBIPAddrRow ) );
            end;
        //3 : //;
        end;
      end;
    end
    else
      List.Add( 'no entries.' );
  end
  else
    List.Add( SysErrorMessage( ErrorCode ) );

  // we must restore pointer!
  dec( pBuf, SizeOf( DWORD ) + NumEntries * SizeOf( IPAddrRow ) );
  FreeMem( pBuf );
end;

//----------------------------------------------------------------------------
function ListaMacAdress(var Nomes, MACs, IPs, Mascaras: TStringList): boolean;//tentativa 1
var
  adapterInfo : Pointer;
  padapterInfo: PIP_ADAPTER_INFO;
  dwBufLen    : LongWord;
  dwStatus    : LongWord;
  i           : integer;
  auxS        : string;
begin
  result:= false;
  //zera para garantir...
  Nomes.Clear;
  MACs.Clear;
  IPs.Clear;
  Mascaras.Clear;
  //
  dwBufLen:= 0;
  adapterInfo:= nil;
  //fun??o maluca do windows que deve ser chamada duas vezes. a primeira para pegar espa?o da memoria...
  GetAdaptersInfo(PIP_ADAPTER_INFO(adapterInfo), dwBufLen);
  if dwBufLen > 0 then
  begin
    //aloca espa?o necess?rio
    GetMem(adapterInfo, dwBufLen);
    //tenta pegar info do primeiro adaptador de rede
    dwStatus:= GetAdaptersInfo(PIP_ADAPTER_INFO(adapterInfo), dwBufLen);
    //testa erro
    if dwStatus = ERROR_SUCCESS then
    begin
      RESULT:= TRUE;
      padapterInfo:= PIP_ADAPTER_INFO(adapterInfo);
    end;//if dwStatus = ERROR_SUCCESS then
    //la?o que vai varrer a lista
    repeat
      //trata adapter atual
      if padapterInfo.Type_ <> MIB_IF_TYPE_TOKENRING then
      begin
        //le nome placa
        auxS:= '';
        auxS:= padapterInfo.AdapterName;
        Nomes.Add(auxS);
        //le mac adress...
        auxS:= '';
        for i:= 0 to MAX_ADAPTER_ADDRESS_LENGTH -1 do
        begin
          auxS:= auxS+IntToHex(padapterInfo.Address[i],2);
          if i < MAX_ADAPTER_ADDRESS_LENGTH -1 then
            auxS:= auxS+'-';
        end;
        MACs.Add(auxS);
        //le IP
        auxS:= '';
        auxS:= padapterInfo.CurrentIpAddress.IpAddress.S;
        IPs.Add(auxS);
        //le Mascara
        auxS:= '';
        auxS:= auxS+padapterInfo.CurrentIpAddress.IpMask.S[i];
        Mascaras.Add(auxS);
      end;
      //passa para o proximo adapter
      padapterInfo:= padapterInfo.Next;
    until (padapterInfo = nil);
    FreeMem(adapterInfo);
  end;//if dwBufLen > 0 then
end;//function ListaMacAdress(var Nomes, MACs, IPs, Mascaras: TStringList): boolean;//tentativa 1

end.
