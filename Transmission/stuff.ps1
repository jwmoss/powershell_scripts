
## transmission 
$url = ""
$securePwd = ConvertTo-SecureString "" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("jwmoss", $securePwd)
try {
    Invoke-WebRequest $url -Headers $headers -errorvariable a -erroraction "Stop" -Credential $credential -AllowUnencryptedAuthentication
}
catch {
    continue
}
$sessionHeader = ($a.Message -split "\.").split(" ")[-1]

$headers = @{
    'X-Transmission-Session-Id' = $sessionHeader
}


$body = @"
{
    "arguments": {
        "fields": ['activityDate', 'addedDate', 'bandwidthPriority', 'comment', 'corruptEver', 'creator', 'dateCreated', 'desiredAvailable', 'doneDate', 'downloadDir', 'downloadedEver', 'downloadLimit', 'downloadLimited', 'error', 'errorString', 'eta', 'files', 'fileStats', 'hashString', 'haveUnchecked', 'haveValid', 'honorsSessionLimits', 'id', 'isFinished', 'isPrivate', 'leftUntilDone', 'magnetLink', 'manualAnnounceTime', 'maxConnectedPeers', 'metadataPercentComplete', 'name', 'peer-limit', 'peers', 'peersConnected', 'peersFrom', 'peersGettingFromUs', 'peersKnown', 'peersSendingToUs', 'percentDone', 'pieces', 'pieceCount', 'pieceSize', 'priorities', 'rateDownload', 'rateUpload', 'recheckProgress', 'seedIdleLimit', 'seedIdleMode', 'seedRatioLimit', 'seedRatioMode', 'sizeWhenDone', 'startDate', 'status', 'trackers', 'trackerStats', 'totalSize', 'torrentFile', 'uploadedEver', 'uploadLimit', 'uploadLimited', 'uploadRatio', 'wanted', 'webseeds', 'webseedsSendingToUs']
    },
    "method": "torrent-get"
 }
"@

$body2 = @"
{
    "arguments":
    {
        "fields": [ "id", "name" ]
    },
    "method": "torrent-get"
}
"@

$splat = @{
    Method = "POST"
    URI = ""
    Headers = $headers
    Credential = $credential
    Body = $body2
}

$t = Invoke-RestMethod @splat -AllowUnencryptedAuthentication