# Create temp folder
$null = New-Item -ItemType Directory -Force -Path temp
$temp = Resolve-Path -Path temp

# Create uploaded folder
$null = New-Item -ItemType Directory -Force -Path "$temp\Uploaded"
$uploaded = Resolve-Path -Path "$temp\Uploaded"

# Find all nuget packages in temp directory
$packages = Dir $temp\*.nupkg

# Ensure we have nuget.exe in temp folder
$nugetVersion = "5.4.0"
$nugetDownloadUrl = "https://dist.nuget.org/win-x86-commandline/v$nugetVersion/nuget.exe"
$nugetExePath = "$temp\nuget.exe"
if (-not (Test-Path -Path $nugetExePath))
{
    Write-Host "Downloading nuget from '$nugetDownloadUrl'"
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($nugetDownloadUrl, $nugetExePath);
}

# Call script to create nuget package
foreach ($package in $packages)
{
    $packagePath = $package.FullName
    $packageName = $package.Name
    Write-Host $packagePath -ForegroundColor Green
    Start-Process -FilePath $nugetExePath -ArgumentList "push `"$packagePath`" -Source https://api.nuget.org/v3/index.json" -Wait -NoNewWindow
    Move-Item -Path $packagePath -Destination "$uploaded\$packageName"
}
