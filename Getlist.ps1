$githubToken = "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"
$headers = @{
    Authorization = "token $githubToken"
    Accept = "application/vnd.github.v3+json"
}
$perPage = 100
$page = 1
$editableRepos = @()  # Array to store repositories where you have push access
$outputFile = "Editable_Repositories.csv"

Write-Host "Fetching repositories where you have push access..."

do {
    $url = "https://api.github.com/user/repos?per_page=$perPage&page=$page"
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -ErrorAction Stop
    }
    catch {
        Write-Host "Error fetching repositories: $_"
        break
    }

    if ($response.Count -eq 0) { break }

    # Filter repositories where user has push access
    $editableRepos += $response | Where-Object { $_.permissions.push -eq $true }
    $page++

} while ($response.Count -eq $perPage)

# Check if there are any repositories with push access
if ($editableRepos.Count -eq 0) {
    Write-Host "No repositories with push access found."
} else {
    # Create CSV file content with the repository URLs
    $csvContent = @()
    $csvContent += '"Repository URL"'  # CSV Header

    foreach ($repo in $editableRepos) {
        $csvContent += "`"$($repo.html_url)`""  # Format for CSV
    }

    # Save the results to a CSV file
    $csvContent -join "`n" | Set-Content -Path $outputFile -Encoding UTF8
    Write-Host "Repositories where you have push access saved to $outputFile"
}
