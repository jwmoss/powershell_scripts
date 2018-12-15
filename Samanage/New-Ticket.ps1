function New-Ticket {
    [CmdletBinding()]
    param (
        [string]$api,
        [string]$ticketname,
        [string]$assignedto
    )

    begin {
        ## Connect to Samanage
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Accept", 'application/vnd.samanage.v2.1+json')
        $headers.Add("X-Samanage-Authorization", "Bearer $api")
        $method = "Post"
        $contenttype = "application/json"
        $uri = "https://api.samanage.com/incidents.json"

        $json = @"
{
	"incident": {
		"name": "$ticketname",
		"assignee": {
			"email": "$assignedto"
        },
        "priority": "CRITICAL",
		"description": "This is a test ticket.",
		"requester": {
			"email": "manager@blah.com"
		},
		"add_to_tag_list": "tag1"
	}
}
"@
    }
	
    process {
        $vars = @{
            URI         = $uri
            Headers     = $headers
            ContentType = $contenttype
            Method      = $method
            Body        = $json
        }
        Invoke-WebRequest @vars
    }
}

