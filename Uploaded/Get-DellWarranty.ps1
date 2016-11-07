Function Get-DellWarranty {
	[cmdletbinding()]
	Param(
		[Parameter(
		 Mandatory=$true,
		 Position=0,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[array]$ServiceTag,
		[Parameter(
		 Mandatory=$false,
		 Position=1)]
		[string]$EntitlementType = "EXTENDED",
		[Parameter(
		 Mandatory=$true,
		 Position=2)]
		[string]$APIKey
	)
		
# 	Possible API keys
# 	1adecee8a60444738f280aad1cd87d0e
# 	d676cf6e1e0ceb8fd14e8cb69acd812d
# 	849e027f476027a394edd656eaef4842

	$WarrantyCollection = @()
	Foreach ($Tag in $ServiceTag) {
		$AssetProps = @{}
		$DellURL = "https://api.dell.com/support/v2/assetinfo/warranty/tags.xml?apikey=$APIKey&svctags=$Tag"
		$DellAPIResponse = Invoke-RestMethod $DellURL
		$DellAsset = $DellAPIResponse.GetAssetWarrantyResponse.GetAssetWarrantyResult.Response.DellAsset
		$Warranties = $DellAsset.Warranties.Warranty | Where-Object {$_.EntitlementType -eq $EntitlementType}
		
		$AssetProps.ServiceTag = $DellAsset.ServiceTag
		$AssetProps.CustomerNumber = $DellAsset.CustomerNumber
		$AssetProps.Description = $DellAsset.MachineDescription
		$AssetProps.ShipDate = $DellAsset.ShipDate
		$AssetProps.OrderNumber = $DellAsset.OrderNumber
		$AssetProps.EntitlementType = $Warranties.EntitlementType
		$AssetProps.StartDate = $Warranties.StartDate
		$AssetProps.EndDate = $Warranties.EndDate
		$AssetProps.ServiceLevelDescription = $Warranties.ServiceLevelDescription
		
		$Asset = New-Object -TypeName PSObject -Property $AssetProps
		$WarrantyCollection += $Asset
	}
	
	Return $WarrantyCollection
}
