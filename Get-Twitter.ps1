
Function Get-511 {
	Invoke-WebRequest "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=511WI&count=2"
	
	return $response
}