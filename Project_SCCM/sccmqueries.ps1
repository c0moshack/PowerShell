Function Get-SCCMDeployment {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0)]
		[string]$SiteServer,
		
		[Parameter(
		Mandatory=$false,
		Position=1)]
		[string]$SiteCode,
				
		[Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$State
	)

	$deployments = get-wmiobject -ComputerName $SiteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_DeploymentInfo
	$statedeployments = $deployments | where {$_.CollectionName -match "^$State\s?-\s.+"}  
	
	return $statedeployments
}

Function Get-SCCMDeploymentInfo {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0)]
		[array]$Deployment
	)
	
	$deploymentdata = @()
	
	Foreach ($one in $Deployment) {
		#Invoke-CMDeploymentSummarization -DeploymentId $($one.DeploymentID) -ErrorAction SilentlyContinue
		$deploymentinfo = Get-CMDeployment -DeploymentId $($one.DeploymentID)
		
		$temp = @{}
		$temp.Collection = $($deploymentinfo.CollectionName)
		$temp.Deployment = $($deploymentinfo.SoftwareName)
		$temp.DeploymentID = $($deploymentinfo.DeploymentID)
		$temp.Started = $($deploymentinfo.DeploymentTime)
		$temp.Total = $($deploymentinfo.NumberTargeted)
		$temp.Complete =  $($deploymentinfo.NumberSuccess)
		$temp.InProgress = $($deploymentinfo.NumberInProgress)
		$temp.Error = $($deploymentinfo.NumberErrors)
		$temp.Unknown = $($($deploymentinfo.NumberOther) + $($deploymentinfo.NumberUnknown))
		
		$deploymentobject = New-Object -TypeName PSObject -Property $temp
		
		$deploymentdata += $deploymentobject
	}
	return $deploymentdata
}

Function Get-SCCMCollection {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SiteServer,
		
		[Parameter(
		Mandatory=$false,
		Position=1,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SiteCode,
				
		[Parameter(
		Mandatory=$false,
		Position=2,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$State
		
	)

	$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection 
	$statecollections = $Collection | where {$_.Name -match "^$State\s-\s.+"}  
	
	$collectiondata = @()
	
	Foreach ($item in $statecollections) {
	
		$temp = @{}
		$temp.CollectionID = $($item.CollectionID)
		$temp.Name = $($item.Name)
		$temp.Comment = $($item.Comment)
		$temp.LocalMemberCount = $($item.LocalMemberCount)
		$temp.MemberCount = $($item.MemberCount)
		$temp.LimitToCollectionID = $($item.LimitToCollectionID)
		$temp.LimitToCollectionName = $($item.LimitToCollectionName)
		
		$collectionobject = New-Object -TypeName PSObject -Property $temp
		
		$collectiondata += $collectionobject
	
	}
	
	return $collectiondata
	
}

$starttime = $(Get-Date)

$params = @{
	SiteServer = 'NGEWA0-SCCM02.ng.ds.army.mil'
	SiteCode = 'NG4'
	State = 'WI'
}	

$collections = Get-SCCMCollection @params | Select Name,CollectionID,LocalMemeberCount,MemberCount,Comment #| ConvertTo-Html | Out-File C:\Users\paul.j.brown\Desktop\SCCMReport.html
$deploymentstatus = Get-SCCMDeploymentInfo -Deployment $(Get-SCCMDeployment @params) | Select Deployment,DeploymentID,Started,Total,InProgress,Complete,Error,Unknown #| ConvertTo-Html | Out-File C:\Users\paul.j.brown\Desktop\SCCMReport.html -Append

$endtime = $(Get-Date)

$head = '<style>BODY{background-color:#DDDDDD;}TABLE{border-width:1px;border-style:solid;border-color:black;border-collapse:collapse;}TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black;}TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black;}</style>'
$title = 'SCCM Status Report'
$body = "Report Start: $starttime <br /> Report End: $endtime <br /> Report Generated: $(Get-Date) <br /> <h2>Device Collections</h2>$($collections | ConvertTo-Html -Fragment) <br /> <h2>Deployments</h2>$($deploymentstatus | ConvertTo-Html -Fragment)"
$reporttime = Get-Date -Format 'yyMMdd-HHmm'
ConvertTo-Html -Head $head -Title $title -Body $body | Out-File C:\Users\paul.j.brown\Desktop\SCCMReports\SCCMReport_$($reporttime).html
Export-PDF -Path "C:\Users\paul.j.brown\Desktop\SCCMReports\*.*" -Extension "*.html"