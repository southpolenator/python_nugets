param(
    [Parameter(Mandatory=$true)][string]$version
)

# Download and extract python installations into directories
& "$PSScriptRoot\ExtractInstallation.ps1" -version $version

# Find temp directory
$temp = Resolve-Path -Path temp

# Create 32bit nuget
$extractedPath32 = "$temp\python32-full-$version"
if (Test-Path -Path $extractedPath32)
{
    & "$PSScriptRoot\CreateNuget.ps1" -extractedPath $extractedPath32 -pythonVersion $version
    Remove-Item -Path $extractedPath32 -Recurse
}

# Create 64bit nuget
$extractedPath64 = "$temp\python64-full-$version"
if (Test-Path -Path $extractedPath64)
{
    & "$PSScriptRoot\CreateNuget.ps1" -extractedPath $extractedPath64 -pythonVersion $version -x64Version
    Remove-Item -Path $extractedPath64 -Recurse
}
