unit uFuncoesDeRede2;

interface

uses
  System.Classes, Winapi.Windows, System.SysUtils, System.Variants,
  ComObj, activeX;

type
  TInfoRede = packed record
    Nome: String;
    IP  : string;
    MASC: string;
    MAC : string;
  end;

  TListaInfoRede = array of TInfoRede;

  procedure GetLista_MAC_Address(lista: TStringList);
  procedure GetIPAddress(lista: TStringList);
  function  Get_Lista_Rede(var ListaInfoRede: TListaInfoRede): integer;
  function  SetStaticIP(descricao, ipnew:string): boolean;

implementation

function VarArrayToStr(const vArray: variant): string;

    function _VarToStr(const V: variant): string;
    var
    Vt: integer;
    begin
    Vt := VarType(V);
        case Vt of
          varSmallint,
          varInteger  : Result := IntToStr(integer(V));
          varSingle,
          varDouble,
          varCurrency : Result := FloatToStr(Double(V));
          varDate     : Result := VarToStr(V);
          varOleStr   : Result := WideString(V);
          varBoolean  : Result := VarToStr(V);
          varVariant  : Result := VarToStr(Variant(V));
          varByte     : Result := char(byte(V));
          varString   : Result := String(V);
          varArray    : Result := VarArrayToStr(Variant(V));
        end;
    end;

var
i : integer;
begin
    Result := '[';
     if (VarType(vArray) and VarArray)=0 then
       Result := _VarToStr(vArray)
    else
    for i := VarArrayLowBound(vArray, 1) to VarArrayHighBound(vArray, 1) do
     if i=VarArrayLowBound(vArray, 1)  then
      Result := Result+_VarToStr(vArray[i])
     else
      Result := Result+'|'+_VarToStr(vArray[i]);

    Result:=Result+']';
end;

//get mac address
procedure GetLista_MAC_Address(lista: TStringList);
const
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT Description,MACAddress FROM Win32_NetworkAdapterConfiguration',
                                         'WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if not VarIsNull(FWbemObject.MACAddress) then
    begin
      lista.Add(Format('Description %s',[String(FWbemObject.Description)]));
      lista.Add(Format('MAC Address %s',[String(FWbemObject.MACAddress)]));
    end;
    //else
    //  lista.Add(Format('  MAC Address %s',['Empty']));
    FWbemObject:=Unassigned;
  end;
end;

//get ip address
procedure GetIPAddress(lista: TStringList);
const
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  i             : Integer;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT IPAddress FROM Win32_NetworkAdapterConfiguration','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if not VarIsClear(FWbemObject.IPAddress) and not VarIsNull(FWbemObject.IPAddress) then
    for i := VarArrayLowBound(FWbemObject.IPAddress, 1) to VarArrayHighBound(FWbemObject.IPAddress, 1) do
     if (Length(String(FWbemObject.IPAddress[i])) <= 15) then
       lista.add(Format('IP Address %s',[String(FWbemObject.IPAddress[i])]));
    FWbemObject:=Unassigned;
  end;
end;

//get info util lista de rede
function Get_Lista_Rede(var ListaInfoRede: TListaInfoRede): integer;
const
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;

  retorno, i    : integer;
begin;
  retorno:= 0;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT Description,IPAddress,IPSubnet,MACAddress FROM Win32_NetworkAdapterConfiguration',
                                         'WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  SetLength(ListaInfoRede, integer(oEnum));
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    if not VarIsNull(FWbemObject.MACAddress) then
    begin
      //descricao
      ListaInfoRede[retorno].Nome:= Format('%s',[String(FWbemObject.Description)]);
      //ip
      if not VarIsClear(FWbemObject.IPAddress) and not VarIsNull(FWbemObject.IPAddress) then
        for i := VarArrayLowBound(FWbemObject.IPAddress, 1) to VarArrayHighBound(FWbemObject.IPAddress, 1) do
          if i = VarArrayLowBound(FWbemObject.IPAddress, 1) then
            ListaInfoRede[retorno].IP:= Format('%s',[String(FWbemObject.IPAddress[i])]);
      //sub rede
      if not VarIsClear(FWbemObject.IPSubnet) and not VarIsNull(FWbemObject.IPSubnet) then
        for i := VarArrayLowBound(FWbemObject.IPSubnet, 1) to VarArrayHighBound(FWbemObject.IPSubnet, 1) do
          if i = VarArrayLowBound(FWbemObject.IPSubnet, 1) then
            ListaInfoRede[retorno].MASC:= Format('%s',[String(FWbemObject.IPSubnet[i])]);
      //mac
      ListaInfoRede[retorno].MAC:=  Format('%s',[String(FWbemObject.MACAddress)]);
      //
      inc(retorno);
    end;//if not VarIsNull(FWbemObject.MACAddress) then
    FWbemObject:=Unassigned;
  end;
  result:= retorno;
end;

//---------SETA IP------------------
function ArrayToVarArray(Arr : Array Of string):OleVariant; overload;
var
 i : integer;
begin
    Result   :=VarArrayCreate([0, High(Arr)], varVariant);
    for i:=Low(Arr) to High(Arr) do
     Result[i]:=Arr[i];
end;

function ArrayToVarArray(Arr : Array Of Word):OleVariant;overload;
var
 i : integer;
begin
    Result   :=VarArrayCreate([0, High(Arr)], varVariant);
    for i:=Low(Arr) to High(Arr) do
     Result[i]:=Arr[i];
end;

function  SetStaticIP(descricao, ipnew:string): boolean;
const
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator      : OLEVariant;
  FWMIService        : OLEVariant;
  FWbemObjectSet     : OLEVariant;
  FWbemObject        : OLEVariant;
  oEnum              : IEnumvariant;
  iValue             : LongWord;
  vIPAddress         : OleVariant;
  vSubnetMask        : OleVariant;
  vDefaultIPGateway  : OleVariant;
  vGatewayCostMetric : OleVariant;

  descricaoLida      : string;
  retorno            : boolean;
begin
  retorno       := true;

  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
  FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled=True','WQL',wbemFlagForwardOnly);
  oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
  while oEnum.Next(1, FWbemObject, iValue) = 0 do
  begin
    //verificar se ? a placa de rede selecionada
    if not VarIsNull(FWbemObject.MACAddress) then
    begin
      //descricao
      descricaoLida:= Format('%s',[String(FWbemObject.Description)]);
      if descricao = descricaoLida then
      begin//
        vIPAddress   := ArrayToVarArray([ipnew{'192.168.1.141'}]);
        vSubnetMask  := ArrayToVarArray(['255.255.255.0']);
        //
        if FWbemObject.EnableStatic(vIPAddress, vSubnetMask) <> 0 then
        begin
          retorno:= false;
          //vDefaultIPGateway  := ArrayToVarArray(['192.168.1.100']);
          //vGatewayCostMetric := ArrayToVarArray([1]);
          //FWbemObject.SetGateways(vDefaultIPGateway,vGatewayCostMetric);
        end;
        //
        VarClear(vIPAddress);
        VarClear(vSubnetMask);
        VarClear(vDefaultIPGateway);
        VarClear(vGatewayCostMetric);
        FWbemObject:=Unassigned;
      end;
    end;//if not VarIsNull(FWbemObject.MACAddress) then
  end;
  result:= retorno;
end;

end.
(*
class Win32_NetworkAdapterConfiguration : CIM_Setting
{
  boolean  ArpAlwaysSourceRoute;
  boolean  ArpUseEtherSNAP;
  string   Caption;
  string   DatabasePath;
  boolean  DeadGWDetectEnabled;
  string   DefaultIPGateway[];
  uint8    DefaultTOS;
  uint8    DefaultTTL;
  string   Description;
  boolean  DHCPEnabled;
  datetime DHCPLeaseExpires;
  datetime DHCPLeaseObtained;
  string   DHCPServer;
  string   DNSDomain;
  string   DNSDomainSuffixSearchOrder[];
  boolean  DNSEnabledForWINSResolution;
  string   DNSHostName;
  string   DNSServerSearchOrder[];
  boolean  DomainDNSRegistrationEnabled;
  uint32   ForwardBufferMemory;
  boolean  FullDNSRegistrationEnabled;
  uint16   GatewayCostMetric[];
  uint8    IGMPLevel;
  uint32   Index;
  uint32   InterfaceIndex;
  string   IPAddress[];
  uint32   IPConnectionMetric;
  boolean  IPEnabled;
  boolean  IPFilterSecurityEnabled;
  boolean  IPPortSecurityEnabled;
  string   IPSecPermitIPProtocols[];
  string   IPSecPermitTCPPorts[];
  string   IPSecPermitUDPPorts[];
  string   IPSubnet[];
  boolean  IPUseZeroBroadcast;
  string   IPXAddress;
  boolean  IPXEnabled;
  uint32   IPXFrameType[];
  uint32   IPXMediaType;
  string   IPXNetworkNumber[];
  string   IPXVirtualNetNumber;
  uint32   KeepAliveInterval;
  uint32   KeepAliveTime;
  string   MACAddress;
  uint32   MTU;
  uint32   NumForwardPackets;
  boolean  PMTUBHDetectEnabled;
  boolean  PMTUDiscoveryEnabled;
  string   ServiceName;
  string   SettingID;
  uint32   TcpipNetbiosOptions;
  uint32   TcpMaxConnectRetransmissions;
  uint32   TcpMaxDataRetransmissions;
  uint32   TcpNumConnections;
  boolean  TcpUseRFC1122UrgentPointer;
  uint16   TcpWindowSize;
  boolean  WINSEnableLMHostsLookup;
  string   WINSHostLookupFile;
  string   WINSPrimaryServer;
  string   WINSScopeID;
  string   WINSSecondaryServer;
};*)

