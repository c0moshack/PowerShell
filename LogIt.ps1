<#   
================================================================================ 
========= LogIt.ps1 ======================================= 
================================================================================ 
 Name: LogIt 
 Purpose: Demonstrate how create and work with Log files using PowerShell 
 Author: Dan Stolts - dstolts&&microsoft.com - http://ITProGuru.com 
 Syntax/Execution: Copy portion of script you want to use and paste into PowerShell (or ISE)  
 Description: Shows how to create log files and create function to log information to screen and text file 
                 Includes ability so set colors and other features 
 Disclaimer: Use at your own Risk!  See details at http://ITProGuru.com/privacy  
 Limitations:  
         * Must Run PowerShell (or ISE)  
        * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
# video of Script https://channel9.msdn.com/Series/GuruPowerShell 
# More scripts from Dan Stolts "ITProGuru" at http://ITProGuru.com/Scripts 
 ================================================================================ 
#> 
$LogFilePath = Get-Location 
$LogFileName = "ITProGuru-LogIt.log"  
$myLog= "$LogFilePath\$LogFileName" 
$myLog 
 
 
function Logit ([string]$TopicName,  
 [string]$message,  
 [string]$ForeGroundColor="Green",  
 [switch]$LogToFile,  
 [string]$LogToFileName="PSLog.log") 
 
    {# Function for displaying formatted log messages and optionally writing them out to a text log file 
        #TopicName      : Classification or short subject of message 
        #message        : Message to log 
        #ForeGroundColor: Identifies the color of the $message  [default =Green] 
        #LogToFile      : Boolean Write log to file [default = $false] 
        #LogToFileName  : File to create if writing to file [default ="PSLog.log"] 
      
     write-host (Get-Date).ToShortTimeString() -ForegroundColor Cyan -NoNewline 
     write-host " - [" -ForegroundColor White -NoNewline 
     write-host $TopicName -ForegroundColor Yellow -NoNewline 
     write-Host "]:: " -ForegroundColor White -NoNewline 
     Write-host $($message) -ForegroundColor $ForeGroundColor 
     If ($LogToFile) { 
         If ($LogToFileName -Like "PSLog.log") {}  # standard logfile being used; do we want to do anything??? }    
            If (Test-Path $LogToFileName)  #Test to see if the log file already exists 
            { 
                # Log File already exists... We will just append to existing file 
                Write-Host (Get-Date).ToString() " Opening Log " $LogToFileName -ForegroundColor Green  # REMOVE/REMARK 
                (Get-Date).ToShortTimeString() + " - [" + $TopicName + "]::" + $message |Out-File $LogToFileName -Append 
            } 
            Else   { 
                # Create the log file   # Need to add some error checking here!!! 
                Write-Host (Get-Date).ToString() " Creating Log " $LogToFileName -ForegroundColor Green   
                (Get-Date).ToShortTimeString() + " - [" + $TopicName + "]::" + $message |Out-File $LogToFileName -Append 
            } 
        } 
   } 
  
  #Examples:  
  logit (HostName) "Write this to screen"  
  logit "Subject" "Write to My Log File!" -ForeGroundColor Red -LogToFile -LogToFileName $MyLog 
  logit (HostName) "Write to default Log File!" -ForeGroundColor Red -LogToFile 
 
 
# video of Script https://channel9.msdn.com/Series/GuruPowerShell  
# More scripts from Dan Stolts "ITProGuru" at http://ITProGuru.com/Scripts