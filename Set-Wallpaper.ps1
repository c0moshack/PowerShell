#set-itemproperty HKCU:\'Control Panel\Desktop'  Wallpaper 'c:\windows\Coffee Bean.bmp'
#RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True

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
   		[String]$FontSize = 20
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
				$color = [System.Drawing.Color]::FromArgb(255, 0, 0,0)
				
				#Set up the brush for drawing image/watermark string
				$myBrush = new-object Drawing.SolidBrush $color
				$rect = New-Object Drawing.Rectangle 0,0,$img.Width,$img.Height
				$gUnit = [Drawing.GraphicsUnit]::Pixel
						
				$ip = $($([System.Net.Dns]::GetHostByName($env:COMPUTERNAME)).AddressList[0].IpAddressToString)
				#at last, draw the water mark
				$gImg.DrawImage($img,$rect,0,0,$img.Width,$img.Height,$gUnit)
				$gImg.DrawString($env:COMPUTERNAME,$font,$myBrush,$($img.Width - 275),[int]$FontSize)
				$gImg.DrawString($ip,$font,$myBrush,$($img.Width - 275),$([int]$FontSize*2)+5)
				If ($text) {
					$gImg.DrawString($text,$font,$myBrush,$($img.Width - 275),$([int]$FontSize*3)+5)
				}
				
				
				if (Test-Path $destination) {
					if (Get-Item $destination | % { $_.PSIsContainer }) {
						$newImagePath = "$destination" + "\watermarked-" + $filename
						#Write-Host $newImagePath
					}
					else {
						Write-Host "$destination isn't a folder. Defaulting to the source location. Watermarked images will be written with a WaterMarked- prefix"
						$newImagePath = "$source" + "\watermarked-" + $filename
					}
				}
				else {
					Write-Host "$destination does not exist. Defaulting to the source location. Watermarked images will be written with a WaterMarked- prefix"
					$newImagePath = "$source" + "\watermarked-" + $filename
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

WaterMark-Image -source "C:\Users\paul.j.brown\Pictures\IMG_42590237820745.jpeg" -destination "C:\Users\paul.j.brown\Pictures" -