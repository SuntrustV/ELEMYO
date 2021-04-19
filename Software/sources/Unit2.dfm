object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'COM '#1087#1086#1088#1090
  ClientHeight = 117
  ClientWidth = 167
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    167
    117)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 3
    Top = 5
    Width = 160
    Height = 110
    Anchors = [akLeft, akTop, akRight, akBottom]
    Shape = bsFrame
    ExplicitWidth = 438
    ExplicitHeight = 205
  end
  object cb1: TComboBox
    Left = 9
    Top = 15
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 46
    Top = 84
    Width = 75
    Height = 25
    Caption = #1054#1082
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object cb2: TComboBox
    Left = 9
    Top = 51
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    Text = '9600'
    Items.Strings = (
      '9600')
  end
end
