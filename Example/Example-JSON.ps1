$subNetworking = @()
$subNetworking += [pscustomobject]@{
    'eternalDNS' = 'somedns';
    'eternalIp' = 'someip'
}

$subSystem = @()
$subSystem += [pscustomobject]@{
    'name' = 'somename';
    'os' = 'someos'
}

$jsondoc = [pscustomobject]@{
    _id = "123"
    system = "thesystemname"
    network = $subNetworking
    systemdata = $subSystem
}