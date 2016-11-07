

Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen

$currentpos = [System.Windows.Forms.Cursor]::Position
[System.Windows.Forms.Cursor]::Position = "$($currentpos.x +10),$($currentpos.Y + 10)"
[System.Windows.Forms.Cursor]::Position = "$($currentpos.x),$($currentpos.Y)"
$newpos = [System.Windows.Forms.Cursor]::Position


$currentpos
$newpos
