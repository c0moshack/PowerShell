Function Speak-Text {
	Param(
		[Parameter(Mandatory=$true)]
		[String]$Text
	)
	
    $Voice = new-object -com "SAPI.SpVoice" -strict
    $Voice.Rate = 0                # Valid Range: -10 to 10, slowest to fastest, 0 default.
    $Voice.Volume = 100
	$Voice.Voice = $($Voice.GetVoices())[1]
	$Voice.Speak($Text) | out-null  # Piped to null to suppress text output.
}