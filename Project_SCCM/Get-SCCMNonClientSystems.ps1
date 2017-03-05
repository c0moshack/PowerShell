Function Get-SCCMCollection {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SiteServer = 'NGEWA0-SCCM02.ng.ds.army.mil',
		
		[Parameter(
		Mandatory=$false,
		Position=1,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SiteCode = 'NG4',
		
		[Parameter(
		Mandatory=$false,
		Position=2,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$CollectionName = 'WI - All Systems',
		
		[Parameter(
		Mandatory=$false,
		Position=2,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$State = 'WI',
		
		[switch]$ListCollections
	)

	If ($ListCollections) {
		$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection 
		$statecollections = $Collection | where {$_.Name -match "^$State\s-\s.+"}  
		return $statecollections
	} Else {
		#Retrieve SCCM collection by name 
		$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection | where {$_.Name -eq "$CollectionName"} 
		#Retrieve members of collection 
		$SMSMemebers = Get-WmiObject -ComputerName $SiteServer -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name" | select Name
		return $SMSMemebers
	}

	
}
Get-SCCMCollection | Export-Csv D:\Programming\Powershell\SCCM\SCCM_WI-All-Systems_041116.csv
