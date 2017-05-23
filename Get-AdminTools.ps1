$global:creds = Get-Credential "<domain\username>"

$fontSize = 12
$fontFamily = "Consolas"
$margin = 0

Show-UI { 
    StackPanel -Margin 1 -Background Red { 
        Label "Admin Tools" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -Foreground "white"
        Button "ADUC" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dsa.msc' -Verb runas"}
        Button "DFS" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dfsmgmt.msc' -Verb runas"}
        Button "DHCP" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dhcpmgmt.msc' -Verb runas"}
        Button "GPMC" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\gpmc.msc' -Verb runas"}
        
        Label "SCCM Tools" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -Foreground "white"
        Button "Console" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\SCCM\AdminConsole\bin\Microsoft.ConfigurationManagement.exe' -Verb runas"}
        Button "Remote Viewer" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\SCCM\AdminConsole\bin\i386\CmRcViewer.exe' -Verb runas"}
        Button "DP Job Viewer" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ServerTools\DPJobMgr.exe' -Verb runas"}
        Button "Content Library Explorer" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ServerTools\ContentLibraryExplorer.exe' -Verb runas"}
        Button "CLI Spy" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CliSpy.exe' -Verb runas"}
        Button "CM Trace" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CMTrace.exe' -Verb runas"}
        Button "Deployment Monitoring Tool" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\DeploymentMonitoringTool.exe' -Verb runas"}
        Button "Wakeup Spy" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\WakeupSpy.exe' -Verb runas"}

        Label "PowerShell" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -Foreground "white"
        Button "Console" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell.exe -Verb runas"}
        Button "ISE" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell_ise.exe -Verb runas"}

        Label "ForeScout" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -Foreground "white"
        Button "Console" -Margin $margin -FontFamily $fontFamily -FontSize $fontSize -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ForeScout CounterACT\GuiManager\current\CounterACT Console.exe' -Verb runas"}


    } 
}

