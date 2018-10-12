$beats = ("auditbeat","filebeat","packetbeat","winlogbeat","metricbeat")

If ( Test-Path "C:\Program Files\Elastic Beats" -eq $false ) {
    New-Item -ItemType Directory -Path "C:\Program Files\" -Name "Elastic Beats"
} 

Foreach ($beat in $beats ) {
    Copy-Item "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\Beats Binaries\$beat-6.2.3-windows-x86_64/*" "C:\Program Files\Elastic Beats\$beat" -Recurse -Force

    Copy-Item "\\ng\ngwi\Public\JFHQ\DISC4-J6\IT_Operations\Elastic\Beats\Windows Clients\*" "C:\Program Files\Elastic Beats" -Recurse -Force

    Set-Location "C:\Program Files\Elastic Beats\$beat" 

    & ./install-service-$beat
}

