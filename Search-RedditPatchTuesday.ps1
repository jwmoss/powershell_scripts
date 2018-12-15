Function Search-RedditPatchTuesday {
    ## Found this on Reddit, saving it for future use. Forgot where it was originally posted :(

    # Get a list of posts from reddit.com/r/sysadmin front page
    $posts = Invoke-RestMethod 'https://www.reddit.com/r/sysadmin/.json'

    # Get the URL for the patch tuesday megathread
    $megathread = $posts.data.children.data.Where{$_.title -like '*Patch Tuesday Megathread*'}
    $megathreadUrl = $megathread.Url

    # Get the comments of the megathread
    $comments = Invoke-RestMethod "$megathreadUrl.json"

    # Iterate through the comments, match any KB#######. Case insensitive, there can be any single character between KB and the numbers.
    $commentTable = $comments.data.children.data.ForEach{
        $match = ([regex]'(?i)kb\d{7}|(?i)kb.\d{7}').Matches($_.body);
        if ($match.Value) {
            # Return a custom object with the data we want to see
            [PSCustomObject] @{
                UpVotes = $_.ups
                KB      = $match.Value -join ', '
                Body    = $_.body
            }
        }
    }

    # Output the data
    $commentTable
}