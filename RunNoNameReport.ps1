$iplist = Import-Csv C:\Users\paul.j.brown\Desktop\NoNetBios.csv 
Get-J6WMIData -ComputerList $iplist | Export-Csv "C:\Users\paul.j.brown\Desktop\NoName_Report.csv"