unit UMsgDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, ExtCtrls;

type
  TMsgDlg = class(TForm)
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    PnBtns: TPanel;
    Btn1: TBitBtn;
    Btn2: TBitBtn;
    Btn3: TBitBtn;
    procedure _FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure Mensagem(aMsg : String);
    function  Pergunta(oCap, aMsg : String): Integer;
  end;

  procedure Mensagem(aMsg : String);
  function  Pergunta(oCap, aMsg : String): Boolean;

implementation

{$R *.DFM}

procedure Mensagem;
var
  MsgDlg: TMsgDlg;
begin
  MsgDlg:= TMsgDlg.Create( Application );
  MsgDlg.Mensagem( aMsg );
  MsgDlg.Free;
end; {### procedure Mensagem ###}

function Pergunta;
var
  MsgDlg: TMsgDlg;
  Retorno: Integer;
begin
  MsgDlg:= TMsgDlg.Create( Application );
  Retorno:= MsgDlg.Pergunta(oCap, aMsg);
  Result:= ( Retorno = mrYes ) or ( Retorno = mrOk );
  MsgDlg.Free;
end; {### function Pergunta ###}

//////////////////////////////////////////////////////////////////////////////
///////////////////////////    TMsgDlg   /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

procedure TMsgDlg._FormKeyDown;
begin
  if ( Key = vk_Escape ) then
  begin
    Btn2.Click;
  end;
end; {### procedure TMsgDlg._FormKeyDown ###}

procedure TMsgDlg.Mensagem;
begin
  // configura textos da janela
  Caption:= 'Atenção';
  Label1.Caption:= aMsg;

  // configura o botão ok
  Btn1.Kind:= bkOK;
  Btn1.Caption:= 'OK';
  Btn1.Left:= (PnBtns.Width - Btn1.Width) div 2;
  Btn1.Top:= (PnBtns.Height - Btn1.Height)div 2;

  // somente o botao ok é visível
  Btn1.Visible:= true;
  Btn2.Visible:= false;
  Btn3.Visible:= false;

  // mostra a janela
  ShowModal;
end; {### procedure TMsgDlg.Mensagem ###}

function TMsgDlg.Pergunta;
var
  Espaco : Integer;
begin
  // configura textos da janela
  Caption:= oCap;
  Label1.Caption:= aMsg;

  // distancia horizontal entre botões
  Espaco:= (PnBtns.Width - 3 * Btn1.Width) div 4;

  // configura o botão sim
  Btn1.Kind:= bkYes;
  Btn1.Caption:= 'Sim';
  Btn1.Left:= Espaco;
  Btn1.Top:= (PnBtns.Height - Btn1.Height)div 2;

  // configura o botão não
  Btn2.Kind:= bkNo;
  Btn2.Caption:= 'Não';
  Btn2.Left:= 2 * Espaco + Btn1.Width;
  Btn2.Top:= Btn1.Top;

  // configura o botão cancela
  Btn3.Kind:= bkCancel;
  Btn3.Caption:= 'Cancela';
  Btn3.Left:= 3 * Espaco + 2 * Btn1.Width;
  Btn3.Top:= Btn1.Top;

  // todos os botões são visíveis
  Btn1.Visible:= true;
  Btn2.Visible:= true;
  Btn3.Visible:= true;

  // mostra a janela
  Result:= ShowModal;
end; {### procedure TMsgDlg.Pergunta ###}

end.
