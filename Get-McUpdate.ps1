$root = $(Get-ADDomain).DistinguishedName
$state = "NGWI"
$searchbase = "OU=$state,OU=States,$root"
$computers = Get-ADComputer -SearchBase $searchbase -Filter *
$servers = $computers #| Where-Object { ($_.Name -like "NGWIA*") -or ($_.Name -like "NGWIB*") -or ($_.Name -like "NGWIC*") }
$nomcupdate = @()
$notonline = @()


Foreach ($server in $servers) {
    $cn = $server.Name
    Write-Output "$cn::Checking machine"
    sleep 5
    If ( Test-Connection -Count 1 -Quiet -BufferSize 16 $cn ) {

        If ( (Get-Item "\\$cn\c$\Program Files (x86)\McAfee\VirusScan Enterprise\mcupdate.exe" -ErrorAction SilentlyContinue) ) {
            
            $mcpath = "\\$cn\c$\Program Files (x86)\McAfee\VirusScan Enterprise\mcupdate.exe"
            Write-Output "$cn::Found mcupdate at $mcpath"

        } ElseIf (Get-Item "\\$cn\c$\Program Files\McAfee\VirusScan Enterprise\mcupdate.exe" -ErrorAction SilentlyContinue) {
            
            $mcpath = "\\$cn\c$\Program Files\McAfee\VirusScan Enterprise\mcupdate.exe"
            Write-Output "$cn::Found mcupdate at $mcpath"

        } Else {
            Write-Warning "$cn::is online but mcupdate is not present."
            $nomcupdate += $server
        }

        If ( $mcpath ) {
            $command = "& '$mcpath' /update"
            Write-Host "$cn::`$mcpath set to $mcpath"   
            Invoke-Command -ComputerName $cn -ScriptBlock { "& $args /update" } -ArgumentList $mcpath
            Write-Output "$cn::Executing mcupdate.exe"
        }

    } Else {
        Write-Warning "$cn::is not online."
        $notonline += $server
    }
}

$nomcupdate | Export-Csv C:\Users\paul.j.brown\Desktop\mcafee_nomcupdate.csv -NoTypeInformation
$notonline | Export-Csv C:\Users\paul.j.brown\Desktop\mcafee_notonline.csv -NoTypeInformation
