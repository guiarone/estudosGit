object FormEscolheCriaPasta: TFormEscolheCriaPasta
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Escolha a pasta'
  ClientHeight = 117
  ClientWidth = 494
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 76
    Width = 494
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object sbtSair: TSpeedButton
      Left = 150
      Top = 0
      Width = 150
      Height = 41
      Cursor = crHandPoint
      Align = alLeft
      Caption = 'Sair'
      Flat = True
      OnClick = sbtSairClick
      ExplicitLeft = 358
    end
    object sbtSelecionar: TSpeedButton
      Left = 0
      Top = 0
      Width = 150
      Height = 41
      Cursor = crHandPoint
      Align = alLeft
      Caption = 'Selecionar'
      Flat = True
      OnClick = sbtSelecionarClick
      ExplicitLeft = 10
      ExplicitTop = 1
      ExplicitHeight = 40
    end
  end
  object edPasta: TEdit
    Left = 24
    Top = 24
    Width = 433
    Height = 24
    TabOrder = 1
    Text = 'edPasta'
  end
end
