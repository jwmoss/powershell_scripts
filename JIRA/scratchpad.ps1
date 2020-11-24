## Connect to JIRA
Set-JiraConfigServer -Server "server"

## Store email and token
$email = "user@domain.com"
$token = "xxxxx"

## Convert to PSCredential
$SecurePassword = $token | ConvertTo-SecureString -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $email, $SecurePassword

## Open a JIRA session
New-JiraSession -Credential $Cred

## Get a JIRA issue by the name INCOL-1234
Get-JiraIssue -Key "INCOL-1234"

## List custom properties and fields required by new jira story
Get-JiraIssueCreateMetadata -Project "INCOL" -IssueType Task

## Get all stories in INCOL that are to-do and created more than 6 weeks ago
$filter = 'project = INCOL AND issuetype = Story AND status = "To Do" AND created >= -6w'

## Get JIRA issue based on the above query
Get-JiraIssue -Query $filter

Foreach ($server in $eolservers) {
    #Write-Host "Decommission/Upgrade $($server.name)"
    $params = @{
        Project = "INCOL"
        IssueType = "Story"
        Summary = "Summary of the JIRA story" 
        Fields = @{
            customfield_10025 = "Jonathan Moss" ## Reporter
        }
        Description = "This is a description of the JIRA story"
    }

    New-JiraIssue @params
}

