param(
    [string]$minimumVersion = "0.0",
    [string]$pythonFtpUrl = "https://www.python.org/ftp/python/"
)

function ExtractVersion([string]$version)
{
    if ($version -match '^\d+[.]\d+$')
    {
        $numbers = $version.Split(".") | ForEach { [int]::parse($_) }
        $numbers += 0
        return $numbers
    }
    elseif ($version -match '^\d+[.]\d+[.]\d+$')
    {
        return $version.Split(".") | ForEach { [int]::parse($_) }
    }
    else
    {
        throw "Invalid version: '$version'"
    }
}

function CompareVersions([array]$version1, [array]$version2)
{
    if ($version1.Length -ne $version2.Length)
    {
        Write-Host $version1
        Write-Host $version1.Length
        Write-Host "-----------"
        Write-Host $version2
        Write-Host $version2.Length
        throw "Arrays need to be of the same length"
    }
    for ($i = 0; $i -lt $version1.Length; $i++)
    {
        if ($version1[$i] -lt $version2[$i])
        {
            return -1
        }
        if ($version1[$i] -gt $version2[$i])
        {
            return 1
        }
    }
    return 0
}

$compareVersion = ExtractVersion -version $minimumVersion

# Get all available python versions and links to their "ftp" directory
$rootHtml = Invoke-WebRequest -Uri $pythonFtpUrl
$versionDirectoryLinks = $rootHtml.Links | Where-Object { $_.innerText -match '^\d+[.]\d+([.]\d+)?/$' }

# Filter versions
$versions = $versionDirectoryLinks | Select-Object -ExpandProperty innerText | ForEach { $_.Trim("/") }
$versions = $versions | Where-Object { (CompareVersions -version1 (ExtractVersion -version $_) -version2 $compareVersion ) -ge 0 }

# Print all versions
$versions
