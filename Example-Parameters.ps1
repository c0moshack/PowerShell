Function Test-Function {
	Param(
  		[Parameter(Mandatory=$True,Position=1)]
   		[string]$computerName,
	
   		[Parameter(Mandatory=$True)]
   		[string]$filePath,
		
		[Parameter(attribute=value, attribute=value)]
    	[string]$variable,
		
		[switch]$DoSomething
	)
}

function Invoke-OnElement {
	param(
	    [parameter(parametersetname="byname")]
	    $username,
	    [parameter(parametersetname="bycomputer")]
	    $computername,
	    $description
	)
	 
	switch($PsCmdlet.ParameterSetName)
	{
	    "byname" { Set-NameProperty -user $username -description $description}
	    "bycomputer" { Set-ComputerProperty -computer $computername -description $description}
	}
}

function Get-SomeValue{
	[CmdletBinding(DefaultParameterSetName="ByUserName")]
	param (
		[parameter(Position=0,
	   	Mandatory=$true,
	   	ParameterSetName="ByUserName")]
	   	[string]$name,
	    
	   	[parameter(Position=1,
	   	Mandatory=$true,
	   	ParameterSetName="ByUserName")]
	   	[string]$Email,
	 
	   	[parameter(Position=0,
	   	ParameterSetName="ByUserId",
	   	ValueFromPipeline=$true,
	   	ValueFromPipelineByPropertyName=$true)]
	   	[ValidateNotNullOrEmpty()]
	   	[int]$id 
	)
	 
    switch ($psCmdlet.ParameterSetName) {
    	"ByUserName"  {#Actions to process for ByUserName
		}
    	"ByUserId"  {#Actions to process for ByUserName
        }
    }
}
###############################################################################
Param(

  [Parameter(Position=0,

      Mandatory=$True,

      ValueFromPipeline=$True)]

  [string]$userName,

  [Parameter(Position=1,

      Mandatory=$True,

      ValueFromPipeline=$True,

      ParameterSetName='EnableUser')]

  [string]$password,

  [Parameter(ParameterSetName='EnableUser')]

  [switch]$enable,

  [Parameter(ParameterSetName='DisableUser')]

  [switch]$disable,

  [string]$computerName = $env:ComputerName,

  [string]$description = "modified via powershell"

 )