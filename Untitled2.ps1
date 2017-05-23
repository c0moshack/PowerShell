$hosts = Import-Csv C:\Users\paul.j.brown\Desktop\Hosts_2017_05_22_08_34.csv
Foreach ( $name in $hosts) {
    $n = ($name.Host -replace "NG\\","")
    If ( Test-Connection -Count 1 -Quiet -BufferSize 16 $n ) {
        & .\SysinternalsSuite\PsExec.exe "\\$n" "\\ngwib7-disc4-10\SCCM Source\ForeScout\32bit\SC-375efe3b2713883e7b03aa1c71e5b2b9b6d2a809ab095011.exe" 
        Write-Output "$n::SecureConnector install attempted"
    } Else {
        Write-Warning "$n::Host not reachable"
    }
}