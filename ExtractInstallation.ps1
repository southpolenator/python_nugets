param(
    [Parameter(Mandatory=$true)][string]$version
)

function CheckIfUrlExists([string]$url)
{
    try
    {
        $httpRequest = [System.Net.WebRequest]::Create($url)
        $httpResponse = $httpRequest.GetResponse()
        $httpStatus = [int]$httpResponse.StatusCode
        $result = $httpStatus -eq 200;
        If (-not ($httpResponse -eq $null))
        {
            $httpResponse.Close();
        }
        return $result;
    }
    catch
    {
        return $false;
    }
}

function DownloadPython([string]$url, [string]$localPath)
{
    Write-Host "Downloading '$url'...";
    try
    {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $localPath);
        return $true;
    }
    catch
    {
        Write-Host " Not found!";
        return $false;
    }
}

function WaitForSetup([string]$setupPath)
{
    # Extract setup name
    $setupName = [System.IO.Path]::GetFileNameWithoutExtension($setupPath)

    # Wait for process to complete
    $running = $true;
    while ($running -eq $true)
    {
        $running = ( ( Get-Process | where ProcessName -eq $setupName).Length -gt 0);
        Start-Sleep -s 1
    }
}

function ExecuteSetup([string]$setupPath, [string]$arguments)
{
    $extension = [System.IO.Path]::GetExtension($setupPath).ToLower();
    if ($extension -eq ".exe")
    {
        Start-Process $setupPath -ArgumentList $arguments -Wait
        WaitForSetup -setupPath $exePath
    }
    elseif ($extension -eq ".msi")
    {
        if (-not $arguments.EndsWith("/uninstall"))
        {
            $arguments = "$arguments /package"
        }
        Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "$arguments `"$setupPath`"" -Wait
    }
}

function ExtractPython([string]$exePath, [string]$installationPath, [string]$extractedPath)
{
    # Install python to specific folder
    Write-Host "Installing '$exePath' to '$installationPath'...";
    ExecuteSetup -setupPath $exePath -arguments "/quiet TargetDir=`"$installationPath`" AssociateFiles=0 Shortcuts=0"

    # Copy everything
    Write-Host "Copy installation to '$extractedPath'...";
    if (Test-Path $extractedPath)
    {
        Remove-Item -Path $extractedPath -Recurse
    }
    Copy-Item -Path $installationPath -Destination $extractedPath -Recurse

    # Uninstall python
    Write-Host "Uninstalling...";
    ExecuteSetup -setupPath $exePath -arguments '/quiet /uninstall'
}

# Create temp folder
$null = New-Item -ItemType Directory -Force -Path temp
$temp = Resolve-Path -Path temp

# 32-bit installation
$downloadUrl32 = "https://www.python.org/ftp/python/$version/python-$version.exe"
$localPath32 = "$temp\python-$version.exe"
$tempInstallationPath = "$temp\installation"
$extractedPath32 = "$temp\python32-full-$version"
if (-not (CheckIfUrlExists -url $downloadUrl32))
{
    $downloadUrl32 = "https://www.python.org/ftp/python/$version/python-$version.msi"
    $localPath32 = "$temp\python-$version.msi"
}
if (DownloadPython -url $downloadUrl32 -localPath $localPath32)
{
    ExtractPython -exePath $localPath32 -installationPath $tempInstallationPath -extractedPath $extractedPath32;
    Remove-Item -Path $localPath32
}

# 64-bit installation
$downloadUrl64 = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
$localPath64 = "$temp\python-$version-amd64.exe"
$extractedPath64 = "$temp\python64-full-$version"
if (-not (CheckIfUrlExists -url $downloadUrl64))
{
    $downloadUrl64 = "https://www.python.org/ftp/python/$version/python-$version.amd64.msi"
    $localPath64 = "$temp\python-$version.amd64.msi"
}

if (DownloadPython -url $downloadUrl64 -localPath $localPath64)
{
    ExtractPython -exePath $localPath64 -installationPath $tempInstallationPath -extractedPath $extractedPath64;
    Remove-Item -Path $localPath64
}
