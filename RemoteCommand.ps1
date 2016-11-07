function Run-RemoteCMD {

	param(
	[Parameter(Mandatory=$true,valuefrompipeline=$true)]
	[string]$compname)
	begin {
		$command = Read-Host " Enter command to run"
		[string]$cmd = "CMD.EXE /C " +$command
						}
	process {
		$newproc = Invoke-WmiMethod -class Win32_process -name Create -ArgumentList ($cmd) -ComputerName $compname
		if ($newproc.ReturnValue -eq 0 )
				{ Write-Output " Command $($command) invoked Sucessfully on $($compname)" }
				# if command is sucessfully invoked it doesn't mean that it did what its supposed to do
				#it means that the command only sucessfully ran on the cmd.exe of the server
				#syntax errors can occur due to user input 
	
	
	
	
	}
	End{Write-Output "Script ...END"}
	 			}
	

#----------------
#you can use this script to run any command that can be run on CMD.EXE
#the following is only to give you an idea how can you use it
#-----------------
#for copying files from many remote computers to a single
# get-content c:\servers.txt | Run-Remotecommand
#Enter command to run: copy c:\log\log.txt d:\
#you only input "copy c:\log\log.txt d:\"
#---------------------------------------
#for forcing group policy update on multiple computers
# get-content c:\servers.txt | Run-Remotecommand
#Enter command to run: gpupdate /force
#--------------------------------------
#for stopping the Bits service on multiple computers
# get-content c:\servers.txt | Run-Remotecommand
#Enter command to run: Net stop bits
#---------
#you can always run it against a single server using 
#Run-RemoteCommand server1
#Enter command to run: enter whatever you'd normally enter in cmd.