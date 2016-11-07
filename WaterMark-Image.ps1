Function WaterMark-Image {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$True)]
   		[String]$source,
  
   		[Parameter(Mandatory=$True)]
   		[String]$destination,
		
		[Parameter(Mandatory=$True)]
   		[String]$text
	)
	
	Process {
		#Load System.Drawing assembly
		[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
		
		#Select a font and instantiate
		$font = new-object System.Drawing.Font("Arial",20,[Drawing.FontStyle]'Bold' )
		
		if (Test-Path $source) {
			if (Get-Item $source | % { $_.PSIsContainer }) {
				#Get all image files from source in to a variable. Add any other image file types to -include
				$files = Get-ChildItem "$source\*.*" -Include *.jpg,*.jpeg,*.bmp,*.png | Select Name,FullName,Directory
				
				$files | ForEach-Object	{
					#Get the image
					Write-Host "processing " $_.Name
					$img = [System.Drawing.Image]::FromFile($_.FullName)
					
					#Create a bitmap
					$bmp = new-object System.Drawing.Bitmap([int]($img.width)),([int]($img.height))
					
					#Intialize Graphics
					$gImg = [System.Drawing.Graphics]::FromImage($bmp)
					$gImg.SmoothingMode = "AntiAlias"
					
					#Set the color required for the watermark. You can change the color combination
					$color = [System.Drawing.Color]::FromArgb(153, 0, 0,0)
					
					#Set up the brush for drawing image/watermark string
					$myBrush = new-object Drawing.SolidBrush $color
					$rect = New-Object Drawing.Rectangle 0,0,$img.Width,$img.Height
					$gUnit = [Drawing.GraphicsUnit]::Pixel
					
					$ip = $($([System.Net.Dns]::GetHostByName($env:COMPUTERNAME)).AddressList[0].IpAddressToString)
					#at last, draw the water mark
					$gImg.DrawImage($img,$rect,0,0,$img.Width,$img.Height,$gUnit)
					$gImg.DrawString($env:COMPUTERNAME,$font,$myBrush,$($img.Width - 275),25)
					$gImg.DrawString($text,$font,$myBrush,$($img.Width - 235),55)
					$gImg.DrawString($ip,$font,$myBrush,$($img.Width - 205),85)
					
					if (Test-Path $destination) {
						if (Get-Item $destination | % { $_.PSIsContainer }) {
							$newImagePath = "$destination" + "\" + $_.Name
							#Write-Host $newImagePath
						}
						else {
							Write-Host "$destination isn't a folder. Defaulting to the source location. Watermarked images will be written with a WaterMarked- prefix"
							$newImagePath = "$source" + "\watermarked-" + $_.Name
						}
					}
					else {
						Write-Host "$destination does not exist. Defaulting to the source location. Watermarked images will be written with a WaterMarked- prefix"
						$newImagePath = "$source" + "\watermarked-" + $_.Name
					}
					$bmp.save($newImagePath,[System.Drawing.Imaging.ImageFormat]::Jpeg)
					$bmp.Dispose()
					$img.Dispose()
				}
			}
			else
			{
				Write-Host "$source is not a valid folder location"
			}
		}
		else {
			Write-Host "$source is not a valid folder location"	
		}
	}
}