##############################################################################
#                                                                            #
#  WDS.psm1                                                                  #
#  Windows Deployment Services (WDS) PowerShell Module                       #                                                                          #
#  Author: Alexander Krause                                                  #
#  Creation Date: 10.03.2013                                                 #
#  Modified Date: 08.04.2013                                                 #
#  Version: 1.7.4                                                            #
#                                                                            #
##############################################################################

function Load-WDSServer($Server = "localhost")
{
$wdsObject = New-Object -ComObject WdsMgmt.WdsManager
$wdsObject.GetWdsServer($Server)
}

function Load-WDSDeviceManager()
{
$wdsObject = New-Object -ComObject WdsMgmt.WdsManager
$wdsObject.GetDeviceManager("")
}

function Get-WDSInstallGroup($Server,$Group = "*")
{
$wds = Load-WDSServer
$grp = $wds.ImageManager.RetrieveInstallImageGroups()
$i = 1;
$li = while($i -le $grp.Count){
   $grp.Item($i)
   $i++} 
$li | ?{$_.Name -like $Group}
}

function Get-WDSInstallImage($Server,$Group = "*")
{
$wds = Load-WDSServer $Server
Get-WDSInstallGroup $Group | %{
$img = $wds.ImageManager.RetrieveInstallImageGroup($_.Name)
$i = 1;
while($i -le $img.RetrieveImages("").Count){
   $img.RetrieveImages("").Item($i)
   $i++
}}
}

function Get-WDSBootGroup($Server,$Architecture)
{
$wds = Load-WDSServer $Server
if($Architecture -eq "x86"){$bit = "x86\Images"}
elseif($Architecture -eq "ia64"){$bit = "ia64\Images"}
elseif($Architecture -eq "x64"){$bit = "x64\Images"}
else{$bit = "*"}
$i = 1;
$li = while($i -le 3){
   $wds.ImageManager.RetrieveBootImageGroup($i)
   $i++}
$li | ?{$_.Name -like $bit}
}

function Get-WDSBootImage($Server,$Architecture = "*")
{
$wds = Load-WDSServer $Server
1..3 | %{
$boot = $wds.ImageManager.RetrieveBootImageGroup($_)
$i = 1;
while($i -le $boot.RetrieveImages("").Count){
   $boot.RetrieveImages("").Item($i)
   $i++
}} | ?{$_.ImageGroup.Name -like $Architecture -or $_.ImageGroup.Name -eq $Architecture+"\Images"}
}

function Get-WDSPendingDevice($Server,$ID = "*",$MAC = "*",$GUID = "*")
{
$wds = Load-WDSServer $Server
$pen = $wds.PendingDeviceManager.GetPendingDevices()
$li = while($pen.Eof -eq $false){
$pen.GetNext()}
$li | ?{$_.RequestId -like $ID -or $_.MacAddress -like $MAC -or $_.Guid -like $GUID}
}

function Get-WDSApprovedDevice($Server)
{
$wds = Load-WDSServer $Server
$app = $wds.PendingDeviceManager.GetApprovedDevices()
while($app.Eof -eq $false){
$app.GetNext()}
}

function Get-WDSRejectedDevice($Server)
{
$wds = Load-WDSServer $Server
$rej = $wds.PendingDeviceManager.GetRejectedDevices()
while($rej.Eof -eq $false){
$rej.GetNext()}
}

function Remove-WDSPendingDevices($Server)
{
$wds = Load-WDSServer $Server
$wds.PendingDeviceManager.DeleteAllPendingDevices()
}

function Remove-WDSApprovedDevices($Server)
{
$wds = Load-WDSServer $Server
$wds.PendingDeviceManager.DeleteAllApprovedDevices()
}

function Remove-WDSRejectedDevices($Server)
{
$wds = Load-WDSServer $Server
$wds.PendingDeviceManager.DeleteAllRejectedDevices()
}

function Get-WDSPrestagedDevice($Device = "*")
{
$wds = Load-WDSDeviceManager
$wds.GetPrestagedDevices()
$li = while($pre.Eof -eq $false){
$pre.GetNext()}
$li | ?{$_.Name -like $Device}
}

function Get-WDSDriverGroup($Server,$Group = "*")
{
$wds = Load-WDSServer $Server
$grp = $wds.DriverManager.RetrieveDriverGroups(0) #auch "" geht!
$i = 1;
$li = while($i -le $grp.Count){
   $grp.Item($i)
   $i++} 
$li | ?{$_.Name -like $Group}
}

function Get-WDSDriver($Server,$Group = "*")
{
$wds = Load-WDSServer $Server
Get-WDSDriverGroup $Group | %{
$dri = $wds.DriverManager.RetrieveDriverGroup($_.Id,0)
$i = 1;
while($i -le $dri.RetrievePackages(0).Count){
   $dri.RetrievePackages(0).Item($i)
   $i++
}}
}

function Get-WDSServer($Server)
{
$wds = Load-WDSServer $Server
$tb = $wds.SetupManager
$ht = @{
Name                           = $wds.Name
DomainName                     = $wds.DomainName
InstallationRoot               = $tb.InstallationRoot
InitialSetupComplete           = $tb.InitialSetupComplete
OperationMode                  = if($tb.OperationMode -eq 1){echo "WdsNotInstalled"}
                                 elseif($tb.OperationMode -eq 2){echo "WdsNotConfigured"}
                                 elseif($tb.OperationMode -eq 3){echo "WdsLegacy"}
                                 elseif($tb.OperationMode -eq 4){echo "WdsMixed"}
                                 elseif($tb.OperationMode -eq 5){echo "WdsNative"}
                                 else{echo $NULL}
UpdateComplete                 = $tb.UpdateComplete
DhcpOperationMode              = if($tb.DhcpOperationMode -eq 1){echo "DhcpNotInstalled"}
                                 elseif($tb.DhcpOperationMode -eq 2){echo "DhcpInactive"}
                                 elseif($tb.DhcpOperationMode -eq 3){echo "DhcpRunning"}
                                 else{echo $NULL}
DhcpPxeOptionPresent           = $tb.DhcpPxeOptionPresent
Version                        = $tb.Version
InstalledFeatures              = $tb.InstalledFeatures
#"BootFiles-Unknown-Installed" = $tb.BootFilesInstalled(0)
"BootFiles-X86-Installed"      = $tb.BootFilesInstalled(1)
"BootFiles-Ia64-Installed"     = $tb.BootFilesInstalled(2)
"BootFiles-X64-Installed"      = $tb.BootFilesInstalled(3)
}
$ht.GetEnumerator() | sort Name | ft -a
}

function Get-WDSConfig($Server)
{
$wds = Load-WDSServer $Server
$cm = $wds.ConfigurationManager
$ts = $wds.TransportServer.ConfigurationManager
$ht = @{
"DeviceAnswerPolicy-AnswerClients"                      = $cm.DeviceAnswerPolicy.AnswerClients;
"DeviceAnswerPolicy-AnswerOnlyKnownClients"             = $cm.DeviceAnswerPolicy.AnswerOnlyKnownClients;
"DeviceAnswerPolicy-ResponseDelay"                      = $cm.DeviceAnswerPolicy.ResponseDelay;
"DirectoryServicesUsePolicy-DefaultDC"                  = $cm.DirectoryServicesUsePolicy.DefaultDC;
"DirectoryServicesUsePolicy-DefaultGC"                  = $cm.DirectoryServicesUsePolicy.DefaultGC;
"DirectoryServicesUsePolicy-PrestageUsingMAC"           = $cm.DirectoryServicesUsePolicy.PrestageUsingMAC;
"DirectoryServicesUsePolicy-NewMachineNamingPolicy"     = $cm.DirectoryServicesUsePolicy.NewMachineNamingPolicy;
"DirectoryServicesUsePolicy-NewMachineOU"               = $cm.DirectoryServicesUsePolicy.NewMachineOU;
"DirectoryServicesUsePolicy-DomainSearchOrder"          = $cm.DirectoryServicesUsePolicy.DomainSearchOrder;
"DirectoryServicesUsePolicy-NewMachineDomainJoinPolicy" = $cm.DirectoryServicesUsePolicy.NewMachineDomainJoinPolicy;
"DirectoryServicesUsePolicy-NewMachineOUType"           = $cm.DirectoryServicesUsePolicy.NewMachineOUType;
"PxeBindPolicy-UseDhcpPorts"                            = $cm.PxeBindPolicy.UseDhcpPorts;
"PxeBindPolicy-RogueDetection"                          = $cm.PxeBindPolicy.RogueDetection;
"PxeBindPolicy-RpcPort"                                 = $cm.PxeBindPolicy.RpcPort;
"BootProgramPolicy-AllowN12ForNewClients"               = $cm.BootProgramPolicy.AllowN12ForNewClients;
"BootProgramPolicy-DiscoverArchitecture"                = $cm.BootProgramPolicy.DiscoverArchitecture;
"BootProgramPolicy-ResetBootProgram"                    = $cm.BootProgramPolicy.ResetBootProgram;
"BootProgramPolicy-AllowServerSelection"                = $cm.BootProgramPolicy.AllowServerSelection;
"BootProgramPolicy-KnownClientPxePromptPolicy"          = $cm.BootProgramPolicy.KnownClientPxePromptPolicy;
"BootProgramPolicy-NewClientPxePromptPolicy"            = $cm.BootProgramPolicy.NewClientPxePromptPolicy;
"PendingDevicesPolicy-PollInterval"                     = $cm.PendingDevicesPolicy.PollInterval;
"PendingDevicesPolicy-MaxRetryCount"                    = $cm.PendingDevicesPolicy.MaxRetryCount;
"PendingDevicesPolicy-Message"                          = $cm.PendingDevicesPolicy.Message;
"PendingDevicesPolicy-Policy"                           = $cm.PendingDevicesPolicy.Policy;
"OSChooserPolicy-MenuName"                              = $cm.OSChooserPolicy.MenuName;
"ImagePolicy-X64ImageType"                              = $cm.ImagePolicy.X64ImageType;
"ClientPolicy-UnattendEnabled"                          = $cm.ClientPolicy.UnattendEnabled;
"ClientPolicy-LoggingEnabled"                           = $cm.ClientPolicy.LoggingEnabled;
"ClientPolicy-LogLevel"                                 = $cm.ClientPolicy.LogLevel;
"ClientPolicy-CommandLineUnattendPrecedence"            = $cm.ClientPolicy.CommandLineUnattendPrecedence;
"AuthorizedForDhcp"                                     = $cm.AuthorizedForDhcp;
#"PxeProviders"                                         = $cm.PxeProviders;
"WdsServicesRunning"                                    = $cm.WdsServicesRunning;
"BindInterfacePolicy-BindPolicy"                        = $cm.BindInterfacePolicy.BindPolicy;
#"BannedGuidPolicy"                                     = $cm.BannedGuidPolicy;
"RefreshPolicy-RefreshPeriod"                           = $cm.RefreshPolicy.RefreshPeriod;
"RefreshPolicy-BcdRefresh"                              = $cm.RefreshPolicy.BcdRefresh;
"RefreshPolicy-BcdRefreshPeriod"                        = $cm.RefreshPolicy.BcdRefreshPeriod;
"ServicePolicy-StartPort"                               = $ts.ServicePolicy.StartPort;
"ServicePolicy-EndPort"                                 = $ts.ServicePolicy.EndPort;
"ServicePolicy-NetworkProfile"                          = $ts.ServicePolicy.NetworkProfile;
}
$ht.GetEnumerator() | sort Name | ft -a
}

Export-ModuleMember Get-WDSInstallGroup,Get-WDSInstallImage,Get-WDSBootGroup,Get-WDSBootImage,Get-WDSPendingDevice,
                    Get-WDSApprovedDevice,Get-WDSRejectedDevice,Remove-WDSPendingDevices,Remove-WDSApprovedDevices,
                    Remove-WDSRejectedDevices,Get-WDSPrestagedDevice,Get-WDSDriverGroup,Get-WDSDriver,Get-WDSServer,
                    Get-WDSConfig