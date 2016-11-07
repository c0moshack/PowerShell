$files = Get-ChildItem "C:\Users\paul.j.brown\Desktop\" -filter "Windows.Defender.lnk" -name

for ($i = 0; $i -lt $files.Count; $i++) {
(New-Object -ComObject shell.application).Namespace('C:\Users\myusername\Desktop\').parsename($files[$i]).invokeverb('pintostartscreen')
}
foreach ($file in $files) {
	$shell = New-Object -ComObject shell.application
	$namespace = $shell.NameSpace("C:\Users\paul.j.brown\Desktop\").parsename($files)
	$verbs = $($namespace.Verbs()).Name
	$namespace.InvokeVerb('Pin to Taskbar')
}

$calc = $($(New-Object -ComObject shell.application).Namespace('C:\Windows\System32\')).parsename('calc.exe')
$($calc.Verbs()).Name
$calc.InvokeVerb('run as administrator')
$calc.v