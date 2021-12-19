using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Retrieve info from body of the request.
$Event_Type = $Request.Headers["x-github-event"]
$Data = $Request.Body
$Action = $Data.action
$Repos_URL = $Data.repository.url
$githubSender = $Data.sender.login

# Invoke the Github API call if a new repo is created
if (($Event_Type -eq "repository") -and ($Action -eq "created")) {
    # Prepare the headers & body of the request
    $githubToken = $env:githubToken
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", "application/vnd.github.v3+json")
    $headers.Add("Authorization", "Bearer $githubToken")
    $headers.Add("Content-Type", "application/json")

    $Protection_Body = "{
        `n    `"required_status_checks`": null,
        `n    `"enforce_admins`": true,
        `n    `"required_pull_request_reviews`": {
        `n        `"dismissal_restrictions`": {},
        `n        `"dismiss_stale_reviews`": false,
        `n        `"require_code_owner_reviews`": true,
        `n        `"required_approving_review_count`": 1
        `n    },
        `n    `"restrictions`": null
        `n}"

    try {        
        $response = Invoke-RestMethod "$Repos_URL/branches/main/protection" -Method 'PUT' -Headers $headers -Body $Protection_Body
        Write-Host $response

        if ($response.StatusCode -lt 300) {
            $Issues_Body = "{
            `n    `"title`": `"Enabled branch protection`",
            `n    `"body`": `"@$githubSender main branch require pull request reviews before merging.`"
            `n}"

            $response = Invoke-RestMethod "$Repos_URL/issues" -Method 'POST' -Headers $headers -Body $Issues_Body
            Write-Host $response
            $Message = "Enabled protection on main brnach and notified issue at @$githubSender "
            Write-Host $Message
            #  write output binding by using the Push-OutputBinding
            Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                    StatusCode = 200
                    Body       = $Message
                })
        }
    }
    catch {
        $Err = $_.Exception
        Write-Host "Error: $Err"
        #  write output binding by using the Push-OutputBinding
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = $Err.Response.StatusCode.Value__
                Body       = $Err.Message
            })
    }
}
else {
    $Message = "Unprocessable Entity: Gihub repository event data not found"
    Write-Host $Message
    #  write output binding by using the Push-OutputBinding
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = 422
            Body       = $Message
        })
}

