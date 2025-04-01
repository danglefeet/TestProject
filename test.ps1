$githubToken = "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"
$headers = @{ Authorization = "token $githubToken" }
$url = "https://api.github.com/user/repos?per_page=100&page=1"

$response = Invoke-RestMethod -Uri $url -Headers $headers
$response | ConvertTo-Json -Depth 3 | Out-File -FilePath "GitHub_API_Response.json" -Encoding UTF8

Write-Host "Raw API response saved to GitHub_API_Response.json"