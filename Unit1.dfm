object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 398
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ComboBox1: TComboBox
    Left = 16
    Top = 16
    Width = 457
    Height = 21
    TabOrder = 0
    Text = 'ComboBox1'
  end
  object Button1: TButton
    Left = 16
    Top = 43
    Width = 273
    Height = 25
    Caption = #21015#20986#25152#26377#35782#21035#24341#25806
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 16
    Top = 128
    Width = 273
    Height = 25
    Caption = #21015#20986#25152#26377#21457#38899#32773
    TabOrder = 2
    OnClick = Button2Click
  end
  object ComboBox2: TComboBox
    Left = 16
    Top = 88
    Width = 457
    Height = 21
    TabOrder = 3
    Text = 'ComboBox2'
  end
  object Button3: TButton
    Left = 312
    Top = 128
    Width = 161
    Height = 25
    Caption = 'Say "Hello"'
    TabOrder = 4
    OnClick = Button3Click
  end
  object SpInprocRecognizer1: TSpInprocRecognizer
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 392
    Top = 304
  end
  object SpInProcRecoContext1: TSpInProcRecoContext
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 400
    Top = 248
  end
  object SpVoice1: TSpVoice
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 440
    Top = 352
  end
end