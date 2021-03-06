unit uEscolheCriaPasta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.Outline, Vcl.Samples.DirOutln, Vcl.StdCtrls;

type
  TFormEscolheCriaPasta = class(TForm)
    Panel1: TPanel;
    sbtSair: TSpeedButton;
    sbtSelecionar: TSpeedButton;
    edPasta: TEdit;
    procedure sbtSelecionarClick(Sender: TObject);
    procedure sbtSairClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEscolheCriaPasta: TFormEscolheCriaPasta;

implementation

{$R *.dfm}

procedure TFormEscolheCriaPasta.sbtSairClick(Sender: TObject);
begin
  close;
end;


procedure TFormEscolheCriaPasta.sbtSelecionarClick(Sender: TObject);
var
  OpenDialog      : TFileOpenDialog;
begin
    OpenDialog := TFileOpenDialog.Create(FormEscolheCriaPasta);
  try
    OpenDialog.Options := OpenDialog.Options + [fdoPickFolders];
    if OpenDialog.Execute then
      edPasta.Text:= OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;
end;

end.
