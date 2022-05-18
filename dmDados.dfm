object dmGeral: TdmGeral
  OldCreateOrder = False
  Height = 461
  Width = 697
  object conGeral: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\UDS\Documents\fontes\ProvaSambaTech\Win32\Debu' +
        'g\base.db'
      'DriverID=SQLite')
    TxOptions.AutoStart = False
    TxOptions.AutoStop = False
    LoginPrompt = False
    Left = 200
    Top = 96
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    DriverID = '8'
    Left = 120
    Top = 40
  end
end
