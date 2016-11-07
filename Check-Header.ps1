function Check-Header
{
       param(
             $path
       )
      
       # Hexidecimal signatures for expected files
       $pdf = '25504446';
       $TIFF_1 = '492049';
       $TIFF_2 = '49492A00';
       $TIFF_3 = '4D4D002A';
       $TIFF_4 = '4D4D002B';
            
       # Get content of each file (up to 4 bytes) for analysis
       ([Byte[]] $fileheader = Get-Content -Path $path -TotalCount 4 -Encoding Byte) |
       ForEach-Object {
             if(("{0:X}" -f $_).length -eq 1)
             {
                   $HeaderAsHexString += "0{0:X}" -f $_
             }
             else
             {
                   $HeaderAsHexString += "{0:X}" -f $_
             }
       }
      
       # Validate file header
       @($pdf, $tiff_1, $tiff_2, $tiff_3, $tiff_4) -contains $HeaderAsHexString
}