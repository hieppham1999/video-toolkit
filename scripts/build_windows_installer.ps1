[CmdletBinding()]
param(
    [string]$Publisher = 'Hiep PT',
    [string]$InnoSetupPath,
    [string]$CertificateThumbprint,
    [string]$TimestampUrl = 'http://timestamp.digicert.com',
    [switch]$SkipClean,
    [switch]$SkipFlutterBuild,
    [switch]$SkipVcRedistDownload
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
$releaseDir = Join-Path $repoRoot 'build\windows\x64\runner\Release'
$installerWorkDir = Join-Path $repoRoot 'build\windows_installer'
$dependencyDir = Join-Path $installerWorkDir 'deps'
$installerOutputDir = Join-Path $repoRoot 'build\installer'
$innoScript = Join-Path $repoRoot 'installer\video_toolkit.iss'
$vcRedistPath = Join-Path $dependencyDir 'vc_redist.x64.exe'
$appExePath = Join-Path $releaseDir 'video_toolkit.exe'

function Assert-LastExitCode {
    param([string]$Operation)
    if ($LASTEXITCODE -ne 0) {
        throw "$Operation failed with exit code $LASTEXITCODE."
    }
}

function Resolve-InnoSetupCompiler {
    if ($InnoSetupPath) {
        if (-not (Test-Path -LiteralPath $InnoSetupPath -PathType Leaf)) {
            throw "ISCC.exe was not found at '$InnoSetupPath'."
        }
        return (Resolve-Path -LiteralPath $InnoSetupPath).Path
    }

    $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe')
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }

    throw 'Inno Setup 6 was not found. Install it or pass -InnoSetupPath.'
}

function Resolve-SignTool {
    $command = Get-Command signtool.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $kitsBin = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
    if (Test-Path -LiteralPath $kitsBin) {
        $candidate = Get-ChildItem -LiteralPath $kitsBin -Directory |
            Sort-Object Name -Descending |
            ForEach-Object {
                $path = Join-Path $_.FullName 'x64\signtool.exe'
                if (Test-Path -LiteralPath $path -PathType Leaf) {
                    $path
                }
            } |
            Select-Object -First 1
        if ($candidate) {
            return $candidate
        }
    }

    throw 'signtool.exe was not found. Install a Windows SDK before signing.'
}

function Sign-Artifact {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$SignToolPath
    )

    & $SignToolPath sign /sha1 $CertificateThumbprint /fd SHA256 /tr $TimestampUrl /td SHA256 $Path
    Assert-LastExitCode "Signing '$Path'"

    & $SignToolPath verify /pa /v $Path
    Assert-LastExitCode "Signature verification for '$Path'"
}

$versionLine = Get-Content -LiteralPath $pubspecPath |
    Where-Object { $_ -match '^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$' } |
    Select-Object -First 1
if (-not $versionLine) {
    throw 'pubspec.yaml must contain a version in the form x.y.z+build.'
}
$null = $versionLine -match '^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$'
$buildName = $Matches[1]
$buildNumber = $Matches[2]

Push-Location $repoRoot
try {
    if (-not $SkipFlutterBuild) {
        $runningApp = Get-CimInstance Win32_Process -Filter "Name = 'video_toolkit.exe'" |
            Where-Object {
                $_.ExecutablePath -and
                [IO.Path]::GetFullPath($_.ExecutablePath) -eq [IO.Path]::GetFullPath($appExePath)
            } |
            Select-Object -First 1
        if ($runningApp) {
            throw (
                'Video Toolkit is running from the release directory. Finish any active encode, ' +
                'close the app, and run this script again.'
            )
        }

        if (-not $SkipClean) {
            & fvm flutter clean
            Assert-LastExitCode 'Flutter clean'
        }
        & fvm flutter pub get
        Assert-LastExitCode 'Flutter pub get'
        & fvm flutter build windows --release --build-name $buildName --build-number $buildNumber
        Assert-LastExitCode 'Flutter Windows release build'
    }

    $requiredFiles = @(
        $appExePath,
        (Join-Path $releaseDir 'flutter_windows.dll'),
        (Join-Path $releaseDir 'data\app.so'),
        (Join-Path $releaseDir 'data\bin\ffmpeg.exe'),
        (Join-Path $releaseDir 'data\bin\ffprobe.exe'),
        (Join-Path $releaseDir 'data\bin\exiftool.exe')
    )
    foreach ($requiredFile in $requiredFiles) {
        if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
            throw "Required release file is missing: $requiredFile"
        }
    }

    New-Item -ItemType Directory -Path $dependencyDir -Force | Out-Null
    New-Item -ItemType Directory -Path $installerOutputDir -Force | Out-Null

    if (-not (Test-Path -LiteralPath $vcRedistPath -PathType Leaf)) {
        if ($SkipVcRedistDownload) {
            throw "VC++ Redistributable is missing at '$vcRedistPath'."
        }
        Write-Host 'Downloading Microsoft Visual C++ x64 Redistributable...'
        Invoke-WebRequest -Uri 'https://aka.ms/vc14/vc_redist.x64.exe' -OutFile $vcRedistPath
    }

    $vcSignature = Get-AuthenticodeSignature -LiteralPath $vcRedistPath
    if ($vcSignature.Status -ne 'Valid' -or
        $vcSignature.SignerCertificate.Subject -notmatch 'Microsoft') {
        throw 'VC++ Redistributable does not have a valid Microsoft signature.'
    }

    if ($CertificateThumbprint) {
        $signToolPath = Resolve-SignTool
        Sign-Artifact -Path $appExePath -SignToolPath $signToolPath
    }
    else {
        Write-Warning 'CertificateThumbprint was not supplied; release artifacts will be unsigned.'
    }

    $compiler = Resolve-InnoSetupCompiler
    & $compiler `
        "/DAppVersion=$buildName" `
        "/DAppPublisher=$Publisher" `
        "/DBuildDir=$releaseDir" `
        "/DOutputDir=$installerOutputDir" `
        "/DVcRedistPath=$vcRedistPath" `
        $innoScript
    Assert-LastExitCode 'Inno Setup compilation'

    $setupPath = Join-Path $installerOutputDir "VideoToolkit-$buildName-x64-Setup.exe"
    if (-not (Test-Path -LiteralPath $setupPath -PathType Leaf)) {
        throw "Expected installer was not created: $setupPath"
    }

    if ($CertificateThumbprint) {
        Sign-Artifact -Path $setupPath -SignToolPath $signToolPath
    }

    $hash = Get-FileHash -LiteralPath $setupPath -Algorithm SHA256
    $checksumPath = "$setupPath.sha256"
    "$($hash.Hash.ToLowerInvariant())  $([IO.Path]::GetFileName($setupPath))" |
        Set-Content -LiteralPath $checksumPath -Encoding ascii

    Write-Host ''
    Write-Host "Installer: $setupPath"
    Write-Host "SHA-256:   $($hash.Hash)"
    Write-Host "Checksum:  $checksumPath"
}
finally {
    Pop-Location
}
