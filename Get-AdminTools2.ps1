Import-Module showui
$global:creds = Get-Credential "<domain\username>"

###########################################################
#                   Custom Functions                      #
###########################################################

###########################################################
#                  End Custom Funtions                    #
###########################################################



Window -ShowInTaskbar -Title "J6 Admin Tools" -Content {
    Grid -Columns Auto,* -Rows Auto,Auto,* -Children {

        StackPanel -Column 0 -Row 0 -RowSpan 3 -Margin 1 -Orientation Vertical -Background Red { 
            Label "Admin Tools"  -Foreground "white"
            Button "ADUC"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dsa.msc' -Verb runas"}
            Button "DFS"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dfsmgmt.msc' -Verb runas"}
            Button "DHCP"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\dhcpmgmt.msc' -Verb runas"}
            Button "GPMC"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell -ArgumentList 'C:\WINDOWS\system32\gpmc.msc' -Verb runas"}
        
            Label "SCCM Tools"  -Foreground "white"
            Button "Console"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft System Center\Configuration Manager\Configuration Manager Console.lnk' -Verb runas"}
            Button "Remote Viewer"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\SCCM\AdminConsole\bin\i386\CmRcViewer.exe' -Verb runas"}
            Button "DP Job Viewer"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ServerTools\DPJobMgr.exe' -Verb runas"}
            Button "Content Library Explorer"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ServerTools\ContentLibraryExplorer.exe' -Verb runas"}
            Button "CLI Spy"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CliSpy.exe' -Verb runas"}
            Button "CM Trace"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CMTrace.exe' -Verb runas"}
            Button "Deployment Monitoring Tool"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\DeploymentMonitoringTool.exe' -Verb runas"}
            Button "Wakeup Spy"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\WakeupSpy.exe' -Verb runas"}

            Label "PowerShell"  -Foreground "white"
            Button "Console"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell.exe -Verb runas" -WorkingDirectory $env:windir}
            Button "ISE"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process powershell_ise.exe -Verb runas" -WorkingDirectory $env:windir}

            Label "ForeScout"  -Foreground "white"
            Button "Console"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\Program Files (x86)\ForeScout CounterACT\GuiManager\current\CounterACT Console.exe' -Verb runas"}

            Label "Microsoft"  -Foreground "white"
            Button "Hyper-V MGR"  -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Hyper-V Manager.lnk' -Verb runas"}

        }

        StackPanel -Row 0 -Column 1 -Orientation Horizontal -Background "gray" -Height 30 {
            Label "Hostname" 
            TextBox -Name "hname" -Width 200
            Label "|" 
            Button "System Details"  -On_Click {
                $COMPUTERNAME = (Get-ChildControl 'hname').Text

                $tempProperties = @{}
                # Get AD Data
                $ad = Get-ADComputer -Credential $global:creds -LDAPFilter "(name=$COMPUTERNAME)" -Properties *
                $tempProperties.LastLogon = $ad.lastLogonDate
                $tempProperties.CN = $ad.CanonicalName
                $tempProperties.Created = $ad.Created
                $tempProperties.Enabled = $ad.Enabled
                $tempProperties.IP = $ad.IPv4Address

                # Get WMI Data
			    $bios = Get-WmiObject -Credential $global:creds -ComputerName $COMPUTERNAME -Class Win32_BIOS -ErrorAction SilentlyContinue
			    $tempProperties.Manufacturer = $bios.Manufacturer
			    $tempProperties.Serial = $bios.SerialNumber

			    $compsys = Get-WmiObject -Credential $global:creds -ComputerName $COMPUTERNAME -Class Win32_ComputerSystem -ErrorAction SilentlyContinue
			    $tempProperties.Model = $compsys.Model
			    $tempProperties.Memory = [math]::truncate($($compsys.TotalPhysicalMemory / 1mb))
			    $tempProperties.Name = $COMPUTERNAME
                $tempProperties.NetBiosName = $compsys.Name

                $ossys = Get-WmiObject -Credential $global:creds -ComputerName $COMPUTERNAME -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
			    $tempProperties.OS = $ossys.Caption

                $tempProperties.BitLocker = $(Get-WmiObject -Credential $global:creds -Namespace root\CIMV2\Security\MicrosoftVolumeEncryption -Class Win32_EncryptableVolume -ComputerName $COMPUTERNAME -ErrorAction SilentlyContinue | Where-Object {$_.DriveLetter -eq "C:"}).ProtectionStatus 

                # Get TPM Data
			    $tpmdata = Get-WmiObject -Credential $global:creds -Namespace root\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm -Property * -ComputerName $COMPUTERNAME -ErrorAction SilentlyContinue
			    $tempProperties.TPMVersion = $tpmdata.PhysicalPresenceVersionInfo
			    $tempProperties.TPMEnabled = $tpmdata.IsEnabled_InitialValue
			    $tempProperties.TPMActivated = $tpmdata.IsActivated_InitialValue

                $tempObject = New-Object -TypeName PSObject -Property $tempProperties

                #(Get-ChildControl "tb").Text += $tempObject | Out-String
                (Get-ChildControl "grid").ItemsSource = @($tempObject)

            }
            Button "Offer RA" -On_Click {Start-Process powershell -Credential $global:creds -ArgumentList "Start-Process 'powershell' -ArgumentList 'C:\Windows\System32\msra.exe /offerra $COMPUTERNAME' -Verb runas"} 
            Button "HIPS Log"  -On_Click {
                $COMPUTERNAME = (Get-ChildControl 'hname').Text
                New-PSDrive -Name "Host_$COMPUTERNAME" -PSProvider FileSystem -Root "\\$COMPUTERNAME\c$" -Credential $global:creds
                (Get-ChildControl "tb").Text = $(Get-Content -Path "Host_$($COMPUTERNAME):\ProgramData\McAfee\Host Intrusion Prevention\HipShield.log" ) | Out-String
                Remove-PSDrive "Host_$COMPUTERNAME"
            }
            Button "Event Log" -On_Click {
                $COMPUTERNAME = (Get-ChildControl 'hname').Text
                $events = Invoke-Command -Credential $global:creds -ComputerName $COMPUTERNAME -ScriptBlock { get-eventlog -ComputerName ngwiwk-disc4-48 -LogName System -After $((Get-Date).AddHours(-1)) }
                (Get-ChildControl "tb").Text = $events | Out-String
            }
        }
        
        ListView -Row 1 -Column 1 -Name "grid" -Height 100 -View {
            GridView -Columns {
                #GridViewColumn -Header 'Name' DisplayMemberBinding 'Name'
                GridViewColumn 'NetBiosName'
                GridViewColumn 'Manufacturer'
                GridViewColumn 'Model'
                GridViewColumn 'Serial'
                GridViewColumn 'OS'
                GridViewColumn 'BitLocker'
                GridViewColumn 'Memory'
                GridViewColumn 'TPMVersion'
                GridViewColumn 'TPMEnabled'
                GridViewColumn 'TPMActivated'
                GridViewColumn 'LastLogon'
                GridViewColumn 'Created'
                GridViewColumn 'Enabled'
                GridViewColumn 'IP'
                GirdViewColumn 'CN'
            }
        }
        TextBox -Name "tb" -Row 2 -Column 1 -TextWrapping Wrap -HorizontalScrollBarVisibility Auto -VerticalScrollBarVisibility Auto -Text ""
        
    }
} -Show