object Form1: TForm1
  Left = 361
  Top = 145
  Caption = 'Form1'
  ClientHeight = 900
  ClientWidth = 1634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  PixelsPerInch = 144
  TextHeight = 25
  object Image1: TImage
    Left = 12
    Top = 12
    Width = 1268
    Height = 867
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    OnClick = DoClickImage
  end
  object Memo1: TMemo
    Left = 1304
    Top = 59
    Width = 315
    Height = 820
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 1302
    Top = 11
    Width = 322
    Height = 38
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'Load image'
    TabOrder = 1
    OnClick = Button1Click
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Image BMP|*.bmp'
    Left = 48
    Top = 64
  end
end
