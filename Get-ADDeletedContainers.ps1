Param ([switch] $LeafObjectsInfo)

$executingDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$domainNCDN = (Get-ADRootDSE).defaultNamingContext

#HT containing GUIDs and the deleted ADObject
$guidObjectHT = @{}
#HT containing GUIDs of the deleted object and corresponding number of deleted immediate subordinates
$guidNumberOfDeletedImmidiateSubordinatesHT = @{}
#HT containing GUIDs of the deleted object and the maximum time gap between the WhenChanged attribute of deleted immediate subordinates
$guidTimeSpanMaxGapBetweenWhenDeletedOfDeletedImmidiateSubordinatesHT = @{}
#HT containing GUIDs and the deleted ADObject' Name
$guidObjectNameHT = @{}
#HT containing GUIDs of parents and corresponding children GUIDs in an HT
$parentGUIDChildrenGUIDHTHT = @{}
#HT containing the DNs of parents which are live
$liveParentsDNHT = @{}

$Global:outputObjects = @()
$Global:lastChildFlag = @()

#Parses the value of msDS-ReplAttributeMetaData and returns the DateTime form of ftimeLastOriginatingChange of the isDeleted attribute
function Get-WhenDeleted([string]$xmlMetadataString)
{
	$xmlObj = [xml]("<root>"+$xmlMetadataString.Replace([char]0,"")+"</root>")
	$whenDeleted = $null
	$xmlObj.root.DS_REPL_ATTR_META_DATA | % {
		if($_.pszAttributeName -eq "isDeleted")
		{
			$whenDeleted = [DateTime]::Parse($_.ftimeLastOriginatingChange)
		}
	}
	return $whenDeleted
}
#Parses the value of msDS-ReplAttributeMetaData and returns the uuidLastOriginatingDsaInvocationID of the isDeleted attribute
function Get-WhereDeletedInvocationID([string]$xmlMetadataString)
{
	$xmlObj = [xml]("<root>"+$xmlMetadataString.Replace([char]0,"")+"</root>")
	$whereDeletedInvocationID = $null
	$xmlObj.root.DS_REPL_ATTR_META_DATA | % {
		if($_.pszAttributeName -eq "isDeleted")
		{
			$whereDeletedInvocationID = $_.uuidLastOriginatingDsaInvocationID
		}
	}
	return $whereDeletedInvocationID
}
#Parses the value of msDS-ReplAttributeMetaData and returns the pszLastOriginatingDsaDN of the isDeleted attribute
function Get-WhereDeletedDSADN([string]$xmlMetadataString)
{
	$xmlObj = [xml]("<root>"+$xmlMetadataString.Replace([char]0,"")+"</root>")
	$whereDeletedDSADN = $null
	$xmlObj.root.DS_REPL_ATTR_META_DATA | % {
		if($_.pszAttributeName -eq "isDeleted")
		{
			$whereDeletedDSADN = $_.pszLastOriginatingDsaDN
		}
	}
	return $whereDeletedDSADN
}
#Processes the Populated HasTables and Populates the output objects
function Populate-Tree([string] $root, [int] $level)
{
	$outputObject = "" | Select DisplayName,Name,ObjectClass,ObjectGUID,WhenDeleted,WhereDeleted,Subordinates
	$outputObject.DisplayName = ""
	for($i = 0; $i -lt $level - 1; $i++) 
	{
		if($Global:lastChildFlag[$i] -eq 0) 
		{
			$outputObject.DisplayName = $outputObject.DisplayName + "¦ "
		} 
		else 
		{
			$outputObject.DisplayName = $outputObject.DisplayName + "  "
		}
	}
	if($level -ne 0) 
	{
		if($Global:lastChildFlag[$level-1] -eq 0) 
		{
			$outputObject.DisplayName = $outputObject.DisplayName + "+-"
		} 
		else 
		{
			$outputObject.DisplayName = $outputObject.DisplayName + "+-"
		}
	}
	if($liveParentsDNHT.Contains($root)) 
	{ 
		$outputObject.DisplayName = $outputObject.DisplayName + $root 
	}
	else 
	{ 
		$outputObject.DisplayName = $outputObject.DisplayName + $guidObjectNameHT[$root]
		$outputObject.Name = $guidObjectNameHT[$root]
		$outputObject.ObjectClass = $guidObjectHT[$root].ObjectClass
		$outputObject.ObjectGUID = $root
		$outputObject.WhenDeleted = Get-WhenDeleted([string]$guidObjectHT[$root]."msDS-ReplAttributeMetaData")
		$outputObject.WhereDeleted = Get-WhereDeletedInvocationID([string]$guidObjectHT[$root]."msDS-ReplAttributeMetaData")
		if($LeafObjectsInfo)
		{
			$numberOfSubordinates = $guidNumberOfDeletedImmidiateSubordinatesHT[$root]
			if($numberOfSubordinates -gt 0)
			{
				$outputObject.Subordinates = $numberOfSubordinates.ToString() + "(" + $guidTimeSpanMaxGapBetweenWhenDeletedOfDeletedImmidiateSubordinatesHT[$root].ToString() + ")"
			}
		}
		$whereDeletedDSADN = Get-WhereDeletedDSADN([string]$guidObjectHT[$root]."msDS-ReplAttributeMetaData")
		$whereDeletedDCName = $null
		if($whereDeletedDSADN)
		{
			#remove the part from the DN to get the DN of the DC object "CN=NTDS Settings,"
			$whereDeletedDCDN = $whereDeletedDSADN.SubString(17,$whereDeletedDSADN.Length-17)
			$whereDeletedDCObject = Get-ADObject -Identity $whereDeletedDCDN -Properties DNSHostName
			if($whereDeletedDCObject)
			{
				$whereDeletedDCName = $whereDeletedDCObject.Name
				if($whereDeletedDCObject.DNSHostName)
				{
					$whereDeletedDCName = $whereDeletedDCObject.DNSHostName
				}
			}
		}
		if($whereDeletedDCName)
		{
			$outputObject.WhereDeleted = $whereDeletedDCName
		}
	}
	$Global:outputObjects = $Global:outputObjects + $outputObject
	if($parentGUIDChildrenGUIDHTHT.Contains($root))
	{
		$children = $parentGUIDChildrenGUIDHTHT[$root]
		$level++
		if($Global:lastChildFlag.Length -lt $level)
		{
			for($j = 0 ; $j -lt $level - $Global:lastChildFlag.Length + 1; $j++) 
			{
				$Global:lastChildFlag = $Global:lastChildFlag + 0
			}
		}
		$childCount = $children.Count
		$counter = 1
		$children.GetEnumerator() | % {
			if($counter -eq $childCount) 
			{
				$Global:lastChildFlag[$level-1] = 1
			}
			else
			{
				$Global:lastChildFlag[$level-1] = 0
			}
			Populate-Tree -root $_.Name -level $level 
			$counter++
		}
	}
}

#populate the hashtables

$deletedObjectsFilter = 'objectClass -eq "organizationalUnit" -or objectClass -eq "container"'
$deletedObjectSearchBase = "CN=Deleted Objects," + $DomainNCDN
$deletedObjectsPropertiesToFetch = @("LastKnownParent","msDS-ReplAttributeMetaData")
Get-ADObject -Filter $deletedObjectsFilter -IncludeDeletedObjects -SearchBase $deletedObjectSearchBase -SearchScope OneLevel -Properties $deletedObjectsPropertiesToFetch | % {
	#extract the name of the object from the mangled RDN
	$name = $_.Name.Split([Char]10)[0]
	#extract the GUID of the object from the mangled RDN
	$guid = $_.Name.Split([Char]10)[1].Substring(4,$_.Name.Split([Char]10)[1].Length - 4)
	
	#insert Object into $guidObjectHT, per its GUID
	if(-not $guidObjectHT.Contains($guid)){$guidObjectHT.Add($guid,$_)}
	#insert Object Name into $guidObjectNameHT, per its GUID
	if(-not $guidObjectNameHT.Contains($guid)){$guidObjectNameHT.Add($guid,$name)}
	
	#If leaf object info is requested
	if($LeafObjectsInfo)
	{
		$distinguishedName = $_.distinguishedName
		$lastKnownParentSearchString = $distinguishedName.Insert($distinguishedName.IndexOf('\0'),"\")
		$deletedImmidiateSubordinates = @(Get-ADObject -IncludeDeletedObjects -Filter 'lastknownparent -eq $lastKnownParentSearchString' -SearchBase $deletedObjectSearchBase -Properties "msDS-ReplAttributeMetaData")
		$deletedImmidiateSubordinatesCount = 0
		if($deletedImmidiateSubordinates)
		{
			$deletedImmidiateSubordinatesCount = $deletedImmidiateSubordinates.Count
			$latestWhenDeleted = [DateTime]::Parse("Jan 01, 1600")
			$oldestWhenDeleted = [DateTime]::Now
			foreach($deletedImmidiateSubordinate in $deletedImmidiateSubordinates)
			{
				$subordinateWhenDeleted = Get-WhenDeleted([string]$deletedImmidiateSubordinate."msDS-ReplAttributeMetaData")
				if($subordinateWhenDeleted -gt $latestWhenDeleted) {$latestWhenDeleted = $subordinateWhenDeleted}
				if($subordinateWhenDeleted -lt $oldestWhenDeleted) {$oldestWhenDeleted = $subordinateWhenDeleted}
			}
			$maxGapBetweenWhenDeletedOfDeletedImmidiateSubordinates = $latestWhenDeleted - $oldestWhenDeleted
			$guidTimeSpanMaxGapBetweenWhenDeletedOfDeletedImmidiateSubordinatesHT.add($guid,$maxGapBetweenWhenDeletedOfDeletedImmidiateSubordinates)
		}
		$guidNumberOfDeletedImmidiateSubordinatesHT.Add($guid,$deletedImmidiateSubordinatesCount);
	}
	
	$parentIsDeleted = $false
	if($_.LastKnownParent.Contains("\0A")) {$parentIsDeleted = $true}
	
	$lastKnownParent = $null
	if($parentIsDeleted) 
	{ 
		$lastKnownParent = $_.LastKnownParent.Substring($_.LastKnownParent.IndexOf("\0A") + 7,36) 
	}
	else 
	{
		$lastKnownParent = $_.LastKnownParent
		if(-not $liveParentsDNHT.Contains($lastKnownParent)){$liveParentsDNHT.Add($lastKnownParent,$null)}
  	}

	#insert ObjectGUID into $parentGUIDChildrenGUIDHTHT, in the HT corresponding to its parent
	if(-not $parentGUIDChildrenGUIDHTHT.Contains($lastKnownParent))
	{
    	$parentGUIDChildrenGUIDHTHT.Add($lastKnownParent,@{$guid=$null})
  	}
  	else
	{
    	$parentGUIDChildrenGUIDHTHT[$lastKnownParent].Add($guid,$null)
  	}
}

$liveParentsDNHT.GetEnumerator() | % {
	Populate-Tree -Root $_.Name -Level 0
}

if($Global:outputObjects)
{
	$Global:outputObjects
	}
