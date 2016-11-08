function Logit ([string]$TopicName = $env:COMPUTERNAME,  
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
  
 write-host (Get-Date) -ForegroundColor Cyan -NoNewline 
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