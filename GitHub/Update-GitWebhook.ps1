function Update-GitWebhook {
    [CmdletBinding()]
    param (
        [string]
        $WebhookURL,

        [string]
        $Token,

        [string]
        $NewWebhookURL
    )
    
    begin {
        $headers = @{
            "Accept"        = "application/vnd.github.v3+json"
            "Authorization" = "token $token"
        }
    }
    
    process {
        ## create the new one
        $body = @{
            config = @{
                url = $NewWebhookURL
            }
        }
    
        Invoke-RestMethod -Uri $WebhookURL -Body ($body | ConvertTo-Json) -Method Patch -Headers $headers
    }
    
    end {
        
    }
}
