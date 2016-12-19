$file = "F:\WII 2015-010 HOFMEISTER WQSRB0 - Copy.xfdl"
$base64 = [Text.Encoding]::GetEncoding(1252).GetString([System.Convert]::FromBase64String($(Get-Content $file))) 
$base64 | Out-File "F:\readme1.txt"
