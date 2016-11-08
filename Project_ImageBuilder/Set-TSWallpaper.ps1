Function WaterMark-Image {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$True)]
   		[String]$source,
  
   		[Parameter(Mandatory=$True)]
   		[String]$destination,
		
		[Parameter(Mandatory=$false)]
   		[String]$text,
		
		[Parameter(Mandatory=$false)]
   		[String]$FontSize = 40
	)
	
	Process {
		#Load System.Drawing assembly
		[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
		
		#Select a font and instantiate
		$font = new-object System.Drawing.Font("Arial",$FontSize,[Drawing.FontStyle]'Bold' )
		$filename = Split-Path -Leaf $source
		
		if (Test-Path $source) {				
				#Get the image
				Write-Host "processing " $source
				$img = [System.Drawing.Image]::FromFile($source)
				
				#Create a bitmap
				$bmp = new-object System.Drawing.Bitmap([int]($img.width)),([int]($img.height))
				
				#Intialize Graphics
				$gImg = [System.Drawing.Graphics]::FromImage($bmp)
				$gImg.SmoothingMode = "AntiAlias"
				
				#Set the color required for the watermark. You can change the color combination
				$color = [System.Drawing.Color]::FromArgb(150, 0, 0, 0)
				
				#Set up the brush for drawing image/watermark string
				$myBrush = new-object Drawing.SolidBrush $color
				$rect = New-Object Drawing.Rectangle 0,0,$img.Width,$img.Height
				$gUnit = [Drawing.GraphicsUnit]::Pixel
						
				$ip = $($([System.Net.Dns]::GetHostByName($env:COMPUTERNAME)).AddressList[0].IpAddressToString)
				#at last, draw the water mark
				$gImg.DrawImage($img,$rect,0,0,$img.Width,$img.Height,$gUnit)
				$gImg.DrawString("NGWI " + $text,$font,$myBrush,$($img.Width - 475),$([int]$FontSize))				
				
				if (Test-Path $destination) {
					if (Get-Item $destination | % { $_.PSIsContainer }) {
						$newImagePath = "$destination" + "\watermarked-" + $filename
						#Write-Host $newImagePath
					}
					else {
						Write-Host "$destination isn't a folder. Defaulting to the source location. Watermarked images will be written with a WaterMarked- prefix"
						If (Test-Path $destination) {
							$img.Dispose()
							Del $destination
						}
						$newImagePath = $destination
					}
				}
				else {
					Write-Host "$destination does not exist. Defaulting to the source location. Watermarked images will be written with a WaterMarked- prefix"
					$newImagePath = $destination
				}
				$format = [System.Drawing.Imaging.ImageFormat]::Jpeg
				$bmp.save($newImagePath,$format)
				$bmp.Dispose()
				$img.Dispose()
		} else {
			Write-Host "$source is not a valid folder location"	
		}
	}
}


# Get the TS variables
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$ScriptRoot = $tsenv.Value("DEPLOYROOT")
#$OSDTargetSystemRoot =  $tsenv.Value("ORIGINALWINDIR")
$OSDTargetSystemRoot = "C:\Windows"
$NGWI = $tsenv.Value("NGWI")
 
# Water-mark the new wallpaper
WaterMark-Image -source "$ScriptRoot\Scripts\CustomScripts\ImageBuilder\Backgrounds\Win7-Chrome-1920x1200.jpg" -destination "$ScriptRoot\Scripts\CustomScripts\ImageBuilder\Backgrounds\img0.jpg" -text $NGWI
 
# Rename default wallpaper
Rename-Item "$OSDTargetSystemRoot\Web\Wallpaper\Windows\img0.jpg" "img1.jpg" -ErrorAction SilentlyContinue
 
# Copy new default wallpaper
Copy-Item "$ScriptRoot\Scripts\CustomScripts\ImageBuilder\Backgrounds\img0.jpg" "$OSDTargetSystemRoot\Web\Wallpaper\Windows\" -Force

