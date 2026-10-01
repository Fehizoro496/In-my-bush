<# : batch portion
@REM Maven Wrapper (only-script flavour) for Windows. Downloads the distribution declared in
@REM .mvn\wrapper\maven-wrapper.properties into %USERPROFILE%\.m2\wrapper\dists and runs it.
@SET __MVNW_ARG0_NAME__=%~nx0
@SET MVNW_BASEDIR=%~dp0
@FOR /F "usebackq tokens=1* delims==" %%A IN (`powershell -noprofile "& {$scriptDir='%~dp0'; $script='%__MVNW_ARG0_NAME__%'; icm -ScriptBlock ([Scriptblock]::Create((Get-Content -Raw '%~f0'))) -NoNewScope}"`) DO @(
  IF "%%A"=="MVN_CMD" (set __MVNW_CMD__=%%B)
)
@IF NOT DEFINED __MVNW_CMD__ (echo Cannot resolve Maven distribution & exit /b 1)
@SET __MVNW_ARG0_NAME__=
@"%__MVNW_CMD__%" %*
@GOTO :EOF
: end batch / begin powershell #>

$ErrorActionPreference = "Stop"
$props = Get-Content -Raw "$scriptDir\.mvn\wrapper\maven-wrapper.properties" | ConvertFrom-StringData
$distributionUrl = $props.distributionUrl
$distFile = $distributionUrl -replace '^.*/', ''
$distName = $distFile -replace '-bin\.(zip|tar\.gz)$', ''
$sha = [System.Security.Cryptography.SHA256]::Create()
$urlHash = (($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($distributionUrl)) | ForEach-Object { $_.ToString("x2") }) -join '').Substring(0, 32)
$userHome = if ($env:MAVEN_USER_HOME) { $env:MAVEN_USER_HOME } else { "$HOME\.m2" }
$mavenHome = "$userHome\wrapper\dists\$distName\$urlHash"
if (-not (Test-Path "$mavenHome\bin\mvn.cmd")) {
  $tmp = New-Item -ItemType Directory -Path ([IO.Path]::Combine([IO.Path]::GetTempPath(), [Guid]::NewGuid()))
  (New-Object Net.WebClient).DownloadFile($distributionUrl, "$tmp\$distFile")
  Expand-Archive "$tmp\$distFile" -DestinationPath $tmp
  New-Item -ItemType Directory -Force -Path (Split-Path $mavenHome) | Out-Null
  Move-Item "$tmp\$distName" $mavenHome
  Remove-Item -Recurse -Force $tmp
}
Write-Output "MVN_CMD=$mavenHome\bin\mvn.cmd"
