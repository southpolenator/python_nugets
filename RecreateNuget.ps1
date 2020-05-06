param(
#    [Parameter(Mandatory=$true)][string]$nugetPath
    [string]$nugetPath = "P:\GitHub\python_nugets\temp\python-full-x64.2.5.0.nupkg"
)

# Extract data from nuget name
$packageName = [System.IO.Path]::GetFileNameWithoutExtension($nugetPath)
$x64Version = $nugetPath -match "python-full-x64"
$pythonVersion = ($packageName -split "-")[-1].Substring(4)

# Create temp folder
$null = New-Item -ItemType Directory -Force -Path temp
$temp = Resolve-Path -Path temp

# Extract tools directory from nuget into a folder
$extractedPath = "$temp\$packageName"
Rename-Item -Path $nugetPath -NewName "$nugetPath.zip"
Expand-Archive -Path "$nugetPath.zip" -DestinationPath $extractedPath
Rename-Item -Path "$nugetPath.zip" -NewName $nugetPath

# Call script to create nuget package
& "$PSScriptRoot\CreateNuget.ps1" -extractedPath $extractedPath\tools -x64Version:$x64Version -pythonVersion $pythonVersion
Remove-Item -Path $extractedPath -Recurse
