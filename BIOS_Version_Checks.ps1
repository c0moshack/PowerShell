wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get SpecVersion
Get-WmiObject -Class SecureBootState -Namespace root\cimv2