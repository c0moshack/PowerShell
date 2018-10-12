$workingpath = 'C:\Users\paul.j.brown\Desktop\Beats Binaries'

$version = "6.2.3"

$beats = ("auditbeat","filebeat","packetbeat","winlogbeat","metricbeat","heartbeat")

Foreach ($beat in $beats) {

    $beatpath = $workingpath + "\$beat-$version-windows-x86_64"

    #& "$beatpath\$beat.exe" -c "$beatpath\$beat.yml" export template --es.version 6.2.3 | Out-File -Encoding UTF8 "$beatpath\$beat.template.json"

    
    $Username = "elastic" 
    $Password = 'Pa$$Word1234567'

    # Encode the credentials to Base64 and setup headers
    $base64creds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($("$($Username):$($Password)")))

    $headers = @{ Authorization = "Basic $base64creds" }
    #Invoke-RestMethod -Headers $headers -UseBasicParsing -Method Put -ContentType "application/json" -InFile "$beatpath\$beat.template.json" -Uri "https://ngwib6-disc4-50.ng.ds.army.mil:9200/_template/$beat-6.2.3"

    & "$beatpath\$beat.exe" -c "$beatpath\$beat.yml" setup --dashboards -E setup.dashboards.always_kibana=true -E setup.dashboards.directory="$beatpath/kibana" -E setup.kibana.host='https://ngwib6-disc4-56.ng.ds.army.mil:5601' -E setup.kibana.username="$Username" -E setup.kibana.password="$Password"
}