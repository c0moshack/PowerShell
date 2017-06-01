Import-Module showui
$global:creds = Get-Credential "<domain\username>"
Window -ShowInTaskbar -Content {
    Grid -Columns Auto,* -Rows Auto,* -Children {

        StackPanel -Column 0 -Row 0 -RowSpan 2 -Margin 1 -Orientation Vertical -Background Red { 
            Label "Admin Tools"  -Foreground "white"
            Button "ADUC"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dsa.msc' -Verb runas"}
            Button "DFS"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dfsmgmt.msc' -Verb runas"}
            Button "DHCP"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dhcpmgmt.msc' -Verb runas"}
            Button "GPMC"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\gpmc.msc' -Verb runas"}
        
            Label "SCCM Tools"  -Foreground "white"
            Button "Console"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\SCCM\AdminConsole\bin\Microsoft.ConfigurationManagement.exe' -Verb runas"}
            Button "Remote Viewer"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\SCCM\AdminConsole\bin\i386\CmRcViewer.exe' -Verb runas"}
            Button "DP Job Viewer"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ServerTools\DPJobMgr.exe' -Verb runas"}
            Button "Content Library Explorer"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ServerTools\ContentLibraryExplorer.exe' -Verb runas"}
            Button "CLI Spy"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CliSpy.exe' -Verb runas"}
            Button "CM Trace"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CMTrace.exe' -Verb runas"}
            Button "Deployment Monitoring Tool"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\DeploymentMonitoringTool.exe' -Verb runas"}
            Button "Wakeup Spy"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\WakeupSpy.exe' -Verb runas"}

            Label "PowerShell"  -Foreground "white"
            Button "Console"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell.exe -Verb runas"}
            Button "ISE"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell_ise.exe -Verb runas"}

            Label "ForeScout"  -Foreground "white"
            Button "Console"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ForeScout CounterACT\GuiManager\current\CounterACT Console.exe' -Verb runas"}
        }

        StackPanel -Row 0 -Column 1 -Orientation Horizontal -Background "gray"{
            Label "Hostname" 
            TextBox -Name "hname" -Width 200
            Label "|" 
            Button "HIPS Log"  -On_Click {(Get-ChildControl "tb").Text = $(Get-Content -Path "\\$((Get-ChildControl 'hname').Text)\c$\ConfigMgrAdminUISetup.log") | Out-String}
            Button "System Details"  -On_Click {$COMPUTERNAME = (Get-ChildControl 'hname').Text; (Get-ChildControl "tb").Text = Start-Process powershell -Credential $global:creds -ArgumentList "-noprofile -command &{Start-Process powershell -ArgumentList 'Get-WMIObject -Class Win32_ComputerSystem -Computer $COMPUTERNAME -Verb runas'}" }
        }
        
        TextBox -Name "tb" -Row 1 -Column 1 -TextWrapping Wrap -HorizontalScrollBarVisibility Auto -VerticalScrollBarVisibility Auto -Text ""
    }
} -Show