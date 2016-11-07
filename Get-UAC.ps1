##############   BEGIN SCRIPT #########################################

###################################################################### 
# SCRIPT: GET-UAC.ps1 
#PURPOSE: Dump accounts that match UserAccountControl value selected 
#          or you can enter customer value 
#    DATE: March 29, 2014 
# 
#         
# REVISON: 1.1 
######################################################################

cls

#Import ActiveDirectory Module if not loaded 
$Module = Get-Module ActiveDIrectory 
If ($Module -eq $Null) {Import-Module ActiveDirectory}

# NOTE – RUN FROM SHELL NOT EDITOR 
# Requires -modules ActiveDirectory

#display Options Menu 
Write-Host “” 
Write-Host -foregroundcolor green “Select the UserAccountControl setting you want to query for:” 
Write-Host “1    SCRIPT     (1, 0x0001)” 
Write-Host “2    ACCOUNTDISABLE     (2, 0x0002)” 
Write-Host “3    HOMEDIR_REQUIRED     (8, 0x0008)” 
Write-Host “4    LOCKOUT     (16, 0x0010)” 
Write-Host “5    PASSWD_NOTREQD     (32, 0x0020)” 
Write-Host “6    PASSWD_CANT_CHANGE     (64, 0x0040)” 
Write-Host “7    ENCRYPTED_TEXT_PWD_ALLOWED     (128, 0x0080)” 
Write-Host “8    TEMP_DUPLICATE_ACCOUNT     (256, 0x0100)” 
Write-Host “9    NORMAL_ACCOUNT     (512, 0x0200)” 
Write-Host “10   INTERDOMAIN_TRUST_ACCOUNT     (2048, 0x0800)” 
Write-Host “11   WORKSTATION_TRUST_ACCOUNT     (4096, 0x1000)” 
Write-Host “12   SERVER_TRUST_ACCOUNT     (8192, 0x2000)” 
Write-Host “13   DONT_EXPIRE_PASSWORD     (65536, 0x10000)” 
Write-Host “14   MNS_LOGON_ACCOUNT     (131072, 0x20000)” 
Write-Host “15   SMARTCARD_REQUIRED     (262144, 0x40000)” 
Write-Host “16   TRUSTED_FOR_DELEGATION     (524288, 0x80000)” 
Write-Host “17   NOT_DELEGATED     (1048576, 0x100000)” 
Write-Host “18   USE_DES_KEY_ONLY     (2097152, 0x200000)” 
Write-Host “19   DONT_REQ_PREAUTH     (4194304, 0x400000)” 
Write-Host “20   PASSWORD_EXPIRED     (8388608, 0x800000)” 
Write-Host “21   TRUSTED_TO_AUTH_FOR_DELEGATION     (16777216, 0x1000000)” 
Write-Host “22   PARTIAL_SECRETS_ACCOUNT     (67108864, 0x04000000 )” 
Write-Host “23   Custom USerAccountControl value” 
Write-host “” 
Write-host “”

#PROMPT user for input 
[int]$a = Read-Host -prompt “Please Select an Option 1-23″

  
# Make sure number entered is not greater than 23 -Show error message 
If ($a -gt 23)  {Write-host -foregroundcolor red “Number must be between 1-23″}

Write-host “” 
Write-host “”

[int]$uacValue = 0

switch ($a) 
{ 
1  {[int]$uacvalue = 1} 
2  {[int]$uacvalue = 2} 
3  {[int]$uacvalue = 8} 
4  {[int]$uacvalue = 16} 
5  {[int]$uacvalue = 32} 
6  {[int]$uacvalue = 64} 
7  {[int]$uacvalue = 128} 
8  {[int]$uacvalue = 256} 
9  {[int]$uacvalue = 512} 
10  {[int]$uacvalue = 2048} 
11  {[int]$uacvalue = 4096} 
12  {[int]$uacvalue = 8192} 
13  {[int]$uacvalue = 65536} 
14  {[int]$uacvalue = 131072} 
15  {[int]$uacvalue = 262144} 
16  {[int]$uacvalue = 524288} 
17  {[int]$uacvalue = 1048576} 
18  {[int]$uacvalue = 2097152} 
19  {[int]$uacvalue = 4194304} 
20  {[int]$uacvalue = 8388608} 
21  {[int]$uacvalue = 16777216} 
22  {[int]$uacvalue = 67108864} 
23  {$b = Read-Host -prompt “Enter custom UserAccountControl value (e.g. 514) “; [int]$uacvalue = $b} 
} 

#WRITE OUTPUT TO SCREEN 
# you can customize the properties displayed for each user by adding properties 
# to Format-Table command (e.g. name,distinguishedname 
$results = Get-ADUser -Filter ‘useraccountcontrol -band $uacvalue’ -Properties useraccountcontrol | Format-Table name 
IF ($results -eq $Null) {Write-Host “No accounts match this criteria”;EXIT} 
  Else 
{$results}

$fileSave = Read-Host -prompt “Do you want to save results to a file? Press Y or N” 
IF ($filesave -eq “y”) {out-file -filepath .\UAC_VALUE_$uacvalue.TXT -inputobject $results -encoding ASCII;Write-host””;Write-host””;Write-Host -foregroundcolor green “Output Saved to UAC_VALUE_$uacvalue.TXT” }

##############   END SCRIPT #########################################