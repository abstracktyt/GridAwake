param()
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   GridAwake - Upload to GitHub" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check git
try {
    $gitVer = & git --version 2>&1
    Write-Host "  Git found: $gitVer" -ForegroundColor DarkGray
} catch {
    Write-Host "  ERROR: Git not found!" -ForegroundColor Red
    Write-Host "  Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Ask username
Write-Host ""
Write-Host "  Enter your GitHub username:" -ForegroundColor White
$GithubUser = Read-Host "  Username"
if (-not $GithubUser) {
    Write-Host "  ERROR: Username cannot be empty" -ForegroundColor Red
    exit 1
}

# Ask repo name
Write-Host ""
Write-Host "  Repository name (press Enter for GridAwake):" -ForegroundColor White
$RepoName = Read-Host "  Repo name"
if (-not $RepoName) { $RepoName = "GridAwake" }

$RepoURL = "https://github.com/" + $GithubUser + "/" + $RepoName + ".git"
Write-Host ""
Write-Host "  Will push to: $RepoURL" -ForegroundColor DarkGray

# Instructions to create repo
Write-Host ""
Write-Host "  STEP 1: Create repository on GitHub" -ForegroundColor Yellow
Write-Host "  ------------------------------------"
Write-Host "  1. Open in browser: https://github.com/new" -ForegroundColor Cyan
Write-Host "  2. Repository name: $RepoName" -ForegroundColor Cyan
Write-Host "  3. Visibility: Public (unlimited free build minutes)" -ForegroundColor Cyan
Write-Host "  4. Click Create repository" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Press ENTER when done..." -ForegroundColor Yellow
$null = Read-Host

# Init git
Set-Location $RepoRoot
Write-Host ""
Write-Host "  [1/5] Initializing git..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    & git init
} else {
    Write-Host "  Already initialized" -ForegroundColor DarkGray
}
Write-Host "  OK" -ForegroundColor Green

# Stage files
Write-Host ""
Write-Host "  [2/5] Staging files..." -ForegroundColor Yellow
& git add .
Write-Host "  OK" -ForegroundColor Green

# Commit
Write-Host ""
Write-Host "  [3/5] Creating commit..." -ForegroundColor Yellow
$commitMsg = "Initial commit: GridAwake Wake-on-LAN v1.0"
& git config user.email "gridawake@noreply.github.com" 2>$null
& git config user.name "GridAwake User" 2>$null
$commitOut = & git commit -m $commitMsg 2>&1
if ($LASTEXITCODE -ne 0) {
    $outStr = $commitOut | Out-String
    if ($outStr -notmatch "nothing to commit") {
        Write-Host "  Commit output: $outStr" -ForegroundColor DarkGray
    } else {
        Write-Host "  Nothing new to commit (OK)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  OK" -ForegroundColor Green
}

# Remote
Write-Host ""
Write-Host "  [4/5] Connecting to GitHub..." -ForegroundColor Yellow
& git remote remove origin 2>$null
& git remote add origin $RepoURL
& git branch -M main
Write-Host "  OK" -ForegroundColor Green

# Token instructions
Write-Host ""
Write-Host "================================================" -ForegroundColor Yellow
Write-Host "  STEP 2: Get a Personal Access Token" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  GitHub no longer accepts passwords." -ForegroundColor White
Write-Host "  You need a Personal Access Token instead." -ForegroundColor White
Write-Host ""
Write-Host "  How to get it:" -ForegroundColor White
Write-Host "  1. Open: https://github.com/settings/tokens/new" -ForegroundColor Cyan
Write-Host "  2. Note: GridAwake" -ForegroundColor Cyan
Write-Host "  3. Expiration: No expiration" -ForegroundColor Cyan
Write-Host "  4. Scopes: check the repo checkbox" -ForegroundColor Cyan
Write-Host "  5. Click Generate token" -ForegroundColor Cyan
Write-Host "  6. COPY the token (shown only once!)" -ForegroundColor Cyan
Write-Host ""
Write-Host "  When git asks for password -> paste the TOKEN" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Press ENTER to start push..." -ForegroundColor Yellow
$null = Read-Host

# Push
Write-Host ""
Write-Host "  [5/5] Pushing to GitHub..." -ForegroundColor Yellow
Write-Host "  Enter username and TOKEN when prompted" -ForegroundColor DarkGray
Write-Host ""
& git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  SUCCESS! Code is now on GitHub!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor White
    Write-Host "  1. Open: https://github.com/$GithubUser/$RepoName" -ForegroundColor Cyan
    Write-Host "  2. Click Actions tab" -ForegroundColor Cyan
    Write-Host "  3. Click: GridAwake iOS Build IPA" -ForegroundColor Cyan
    Write-Host "  4. Click Run workflow -> Run workflow" -ForegroundColor Cyan
    Write-Host "  5. Wait 15-20 min for the build to finish" -ForegroundColor Cyan
    Write-Host "  6. Download .ipa from Artifacts section" -ForegroundColor Cyan
    Write-Host "  7. Install on iPhone via Sideloadly (sideloadly.io)" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "  Open GitHub Actions in browser? (y/n):" -ForegroundColor White
    $openBrowser = Read-Host "  Answer"
    if ($openBrowser -eq "y") {
        Start-Process ("https://github.com/" + $GithubUser + "/" + $RepoName + "/actions")
    }
} else {
    Write-Host ""
    Write-Host "  ERROR: Push failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Check:" -ForegroundColor Yellow
    Write-Host "  - Repo exists: https://github.com/$GithubUser/$RepoName" -ForegroundColor Yellow
    Write-Host "  - Token has repo scope enabled" -ForegroundColor Yellow
    Write-Host "  - Username is correct" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Try manually in PowerShell:" -ForegroundColor White
    Write-Host "  cd d:\GridAwake" -ForegroundColor DarkGray
    Write-Host "  git push -u origin main" -ForegroundColor DarkGray
    exit 1
}
