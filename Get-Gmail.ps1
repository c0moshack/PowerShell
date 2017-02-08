$webclient = new-object System.Net.WebClient
$webclient.Credentials = new-object System.Net.NetworkCredential ("paulbrown4@gmail.com", "jasi51408")
[xml]$xml= $webclient.DownloadString("https://mail.google.com/mail/feed/atom")
$format= @{Expression={$_.title};Label="Title"},@{Expression={$_.author.name};Label="Author"}
$xml.feed.entry | format-table $format