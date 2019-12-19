## https://gcits.com/knowledge-base/sync-office-365-users-mailchimp-list/

function Get-MailChimpContacts {
    [CmdletBinding()]
    param (
        [string]
        $APIKey,

        [string]
        $BaseURI = "https://us4.api.mailchimp.com"
    )
    
    begin {

        $user = "anythingGoesHere"
        $pair = "${user}:${apiKey}"
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $basicAuthValue = "Basic $base64"
        $Headers = @{
            Authorization = $basicAuthValue
        }
    }
    
    process {

        $lists = Invoke-RestMethod -URI "$baseUri/3.0/lists?offset=0&count=100" -Method Get -Headers $Headers
    
        $listID = $lists.lists.id
    
        $existingMembers = $null
        $existingmembers = Invoke-RestMethod -URI "$baseUri/3.0/lists/$listId/members?offset=0&count=100" -Method Get -Headers $Headers
        for ($i = 100; $i -le $existingMembers.total_items; $i += 100) {
            $members = Invoke-RestMethod -URI "$baseUri/3.0/lists/$listId/members?offset=$i&count=100" -Method Get -Headers $Headers
            $existingMembers.members += $members.members
        }
        
    }
    
    end {
        return $existingMembers
    }
}