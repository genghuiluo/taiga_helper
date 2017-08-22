Set objExcel = CreateObject("Excel.Application")
objExcel.Application.Run "'C:\cygwin64\home\chinacscs\project\github\taiga_helper\vba-tool\taiga_helper_v2.xlsm'!AutoRefresh.call_by_vbs"
objExcel.ActiveWorkbook.Save
objExcel.DisplayAlerts = False
objExcel.Application.Quit
Set objExcel = Nothing