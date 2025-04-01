# Set your GitHub token and GitHub user
$githubToken = "x"
$repoOwner = "danglefeet"
$repoName = "TestProject"
$issueTitle = "Test Issue"
$issueBody = "This is a test issue for tracking purposes."


param (
    [string]$repoOwner,  # Owner of the repository
    [string]$repoName,   # Repository name
    [string]$githubToken # Your GitHub Personal Access Token
)

# GitHub API URLs
$forkUrl = "https://api.github.com/repos/$repoOwner/$repoName/forks"
$issueUrl = "https://api.github.com/repos/$repoOwner/$repoName/issues"
$pullRequestUrl = "https://api.github.com/repos/$repoOwner/$repoName/pulls"
$reviewUrlBase = "https://api.github.com/repos/$repoOwner/$repoName/pulls"

# Authentication header
$headers = @{
    Authorization = "token $githubToken"
    Accept        = "application/vnd.github.v3+json"
}

# Generate random counts for each action
$issueCount = Get-Random -Minimum 1 -Maximum 4
$pullRequestCount = Get-Random -Minimum 1 -Maximum 3
$pushCount = Get-Random -Minimum 1 -Maximum 3
$codeReviewCount = Get-Random -Minimum 1 -Maximum 2

Write-Host "Randomly chosen actions:"
Write-Host " - Issues to create: $issueCount"
Write-Host " - Pull Requests: $pullRequestCount"
Write-Host " - Pushes: $pushCount"
Write-Host " - Code Reviews: $codeReviewCount"

# Step 1: Fork the repository (Only done once)
Write-Host "Forking the repository..."
$forkResponse = Invoke-RestMethod -Uri $forkUrl -Method Post -Headers $headers
$forkedRepo = $forkResponse.full_name
Write-Host "Forked repository: $forkedRepo"

# Clone the forked repository
$localRepoPath = "$env:TEMP\$repoName"
Write-Host "Cloning repository to $localRepoPath..."
git clone $forkResponse.clone_url $localRepoPath
Set-Location $localRepoPath

# Step 2: Perform Random Pushes (Modify README.md)
for ($i = 1; $i -le $pushCount; $i++) {
    $branchName = "random-change-$(Get-Date -Format 'yyyyMMddHHmmss')-$i"
    Write-Host "Creating branch: $branchName"
    git checkout -b $branchName
    Add-Content -Path "$localRepoPath\README.md" -Value " "  # Adding a space
    git add README.md
    git commit -m "Randomized change to README"
    git push origin $branchName
    Write-Host "Pushed changes to branch: $branchName"
}

# Step 3: Create Random Pull Requests
for ($i = 1; $i -le $pullRequestCount; $i++) {
    $branchName = "random-change-$(Get-Date -Format 'yyyyMMddHHmmss')-$i"
 $headBranch = "$env:USERNAME:$branchName"  # Reference your forked branch correctly
$prBody = @{
    title = "Random Contribution #$i"
    head  = "$headBranch"
    base  = "main"
    body  = "This is an automated random contribution."
} | ConvertTo-Json -Depth 3

    Write-Host "Creating Pull Request #$i..."
    $prResponse = Invoke-RestMethod -Uri $pullRequestUrl -Method Post -Headers $headers -Body $prBody
    Write-Host "Pull Request created: $($prResponse.html_url)"
}

# Step 4: Create Random Issues with Different Content
$issueTemplates = @(
    "There's a minor formatting issue in README.md",
    "Feature request: Add more examples to the documentation",
    "Bug: The installation guide is missing a step",
    "Enhancement: Consider refactoring for better readability"
)

for ($i = 1; $i -le $issueCount; $i++) {
    $randomIssue = $issueTemplates | Get-Random
    $issueBody = @{
        title = "Random Issue #$i"
        body  = $randomIssue
    } | ConvertTo-Json -Depth 3

    Write-Host "Creating Issue #$i..."
    $issueResponse = Invoke-RestMethod -Uri $issueUrl -Method Post -Headers $headers -Body $issueBody
    $issueNumber = $issueResponse.number
    Write-Host "Issue created: $($issueResponse.html_url)"

    # Randomly decide whether to close the issue (50% chance)
    if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) {
        Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)  # Random delay
        $closeIssueBody = @{ state = "closed" } | ConvertTo-Json -Depth 3
        Write-Host "Closing Issue #$i..."
        $closeIssueUrl = "https://api.github.com/repos/$repoOwner/$repoName/issues/$issueNumber"
        Invoke-RestMethod -Uri $closeIssueUrl -Method Patch -Headers $headers -Body $closeIssueBody
        Write-Host "Issue #$issueNumber closed."
    }
}

# Step 5: Submit Random Code Reviews
for ($i = 1; $i -le $codeReviewCount; $i++) {
    # Get a random PR number from previous PRs
    $prNumber = Get-Random -Minimum 1 -Maximum ($pullRequestCount + 1)

    # Define review body
    $reviewBody = @{
        event = "APPROVE"
        body  = "This change looks good!"
    } | ConvertTo-Json -Depth 3

    $reviewUrl = "$reviewUrlBase/$prNumber/reviews"
    Write-Host "Submitting Code Review #$i for PR #$prNumber..."
    Invoke-RestMethod -Uri $reviewUrl -Method Post -Headers $headers -Body $reviewBody
    Write-Host "Code review submitted for PR #$prNumber."
}

Write-Host "Randomized process completed successfully!"
