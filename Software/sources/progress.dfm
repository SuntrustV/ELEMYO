object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 53
  ClientWidth = 443
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 443
    Height = 53
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 152
    ExplicitTop = 136
    ExplicitWidth = 185
    ExplicitHeight = 41
    DesignSize = (
      443
      53)
    object Bevel1: TBevel
      Left = 5
      Top = 5
      Width = 435
      Height = 45
      Anchors = [akLeft, akTop, akRight, akBottom]
      Shape = bsFrame
      ExplicitWidth = 455
      ExplicitHeight = 232
    end
    object g1: TGauge
      Left = 15
      Top = 16
      Width = 414
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      ForeColor = clBlue
      Progress = 0
    end
  end
end
