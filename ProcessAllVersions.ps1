param(
    [string]$minimumVersion = "2.4"
)

# Get all available versions
$versions = & "$PSScriptRoot\FindAllVersions.ps1" -minimumVersion $minimumVersion

foreach ($version in $versions)
{
    Write-Host $version -ForegroundColor Green
    & "$PSScriptRoot\PythonNuget.ps1" -version $version
}
