param(
    [Parameter(Mandatory=$true)][string]$extractedPath,
    [switch]$x64Version = $false,
    [Parameter(Mandatory=$true)][string]$pythonVersion
)

# Package variables
$bitVersionString = if ($x64Version) { "x64" } else { "x86" }
$packageId = "python-full-$bitVersionString"
$packageName = "$packageId-$pythonVersion"

# Create temp folder
$null = New-Item -ItemType Directory -Force -Path temp
$temp = Resolve-Path -Path temp

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

# Create simple props file that will share python tools location
$propsName = "$packageId.props"
$propsPath = "$temp\$propsName"
@"
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <PythonFull$bitVersionString>`$(MSBuildThisFileDirectory)..\..\Tools</PythonFull$bitVersionString>
  </PropertyGroup>
</Project>
"@ | Out-File -FilePath $propsPath

# Create nuspec
$nuspecPath = "$temp\$packageName.nuspec"
Write-Host "Creating nuspec '$nuspecPath'..."
@"
<?xml version="1.0" encoding="utf-8" ?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/10/nuspec.xsd">
  <metadata>
    <id>$packageId</id>
    <version>$pythonVersion</version>
    <description>Python environment extracted from official installation for Windows.</description>
    <authors>Python Software Foundation</authors>
    <owners>Python Software Foundation</owners>
    <projectUrl>https://www.python.org/</projectUrl>
    <iconUrl>https://www.python.org/static/favicon.ico</iconUrl>
    <repository type="git" url="https://github.com/Python/CPython.git" />
    <license type="file">Tools\LICENSE.txt</license>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <tags>python</tags>
  </metadata>
  <files>
    <file src="$extractedPath\**" target="tools" />
    <file src="$propsPath" target="build\native" />
  </files>
</package>
"@ | Out-File -FilePath $nuspecPath

# Create nuget package
Write-Host "Packaging '$extractedPath'..."
Start-Process -FilePath $nugetExePath -ArgumentList "pack `"$nuspecPath`" -OutputDirectory `"$temp`"" -Wait

# Delete temporary files
Remove-Item -Path $propsPath
Remove-Item -Path $nuspecPath
