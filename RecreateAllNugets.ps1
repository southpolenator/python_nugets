# Create temp folder
$null = New-Item -ItemType Directory -Force -Path temp
$temp = Resolve-Path -Path temp

# Find all nuget packages in temp directory
$packages = Dir $temp\*.nupkg

# Call script to create nuget package
foreach ($package in $packages)
{
    $packagePath = $package.FullName
    Write-Host $packagePath -ForegroundColor Green
    & "$PSScriptRoot\RecreateNuget.ps1" -nugetPath $packagePath
}
