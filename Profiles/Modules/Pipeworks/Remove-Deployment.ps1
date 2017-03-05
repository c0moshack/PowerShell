function Remove-Deployment
{
    <#
    .Synopsis
        Removes a Pipeworks deployment
    .Description
        Removes a Pipeworks deployment from the list of deployments 
    .Example
        Remove-Deployment -Name EZOut # Removes EZOut from the list of deployed modules
    .Link
        Get-Deployment
    .Link
        Add-Deployment
    #>
    [CmdletBinding(ConfirmImpact='High')]
    [OutputType([Nullable])]
    param(
    # The name of the module to remove from the deployment
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [string]
    $Name
    )

    process {
        if ($PSCmdlet.ShouldProcess("Remove $Name")) {
            $existingDeployments = Get-SecureSetting -Name "PipeworksDeployments" -ValueOnly

            if (-not $existingDeployments) {
                $existingDeployments = @{}
            }
            $existingDeployments.Remove($name)

            Add-SecureSetting -Name PipeworksDeployments -Hashtable $existingDeployments
        }
    }
}
