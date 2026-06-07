$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile(
    "d:\GridAwake\github-deploy\push_to_github.ps1",
    [ref]$null,
    [ref]$errors
)
if ($errors.Count -eq 0) {
    Write-Host "Syntax OK - no errors" -ForegroundColor Green
} else {
    $errors | ForEach-Object { Write-Host $_.Message -ForegroundColor Red }
}
