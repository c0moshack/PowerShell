
$fileset = "SCCM Servers"
$beats = ("auditbeat","filebeat","winlogbeat","metricbeat") # heartbeat,packetbeat not included
Foreach ($beat in $beats ) {
    Copy-Item "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\Beats Binaries\$beat-6.2.3-windows-x86_64\*" "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\$fileset\_Merged\Elastic Beats\$beat" -Recurse -Force 

    Copy-Item "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\$fileset\Configs\*" "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\$fileset\_Merged\Elastic Beats\" -Recurse -Force
}



$computername = "NGWIB7-DISC4-10"

Copy-Item "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\$fileset\_Merged\Elastic Beats" "\\$computername\C$\Program Files" -recurse -force
Copy-Item "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\WinPcap_4_1_3.exe" "\\$computername\c$\Program Files\Elastic Beats\"

Get-ChildItem "\\$computername\c$\Program Files\Elastic Beats"
$answer = Read-Host "Would you like to connect and install/start the services?"

If ( $answer.ToLower() -eq "y" ) {
    Enter-PSSession $computername
    Get-ChildItem "C:\Program Files\Elastic Beats"
    $beats = ("auditbeat","filebeat","packetbeat","winlogbeat","metricbeat")
    Foreach ($beat in $beats ) {
        Set-Location "C:\Program Files\Elastic Beats\$beat" 

        & ./install-service-$beat
        Start-Service $beat
    }
    Exit-PSSession
}