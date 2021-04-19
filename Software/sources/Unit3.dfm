object Form3: TForm3
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 80
  ClientWidth = 589
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 589
    Height = 80
    Align = alClient
    Color = clGray
    ParentBackground = False
    TabOrder = 0
    ExplicitHeight = 235
    DesignSize = (
      589
      80)
    object Bevel1: TBevel
      Left = 6
      Top = 6
      Width = 577
      Height = 68
      Anchors = [akLeft, akTop, akRight, akBottom]
      Shape = bsFrame
      ExplicitWidth = 451
      ExplicitHeight = 228
    end
    object Gauge1: TGauge
      Left = 16
      Top = 29
      Width = 555
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      ForeColor = clBlue
      Progress = 0
    end
  end
end
