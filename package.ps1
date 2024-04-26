# Copyright (c) 2024 Roger Brown.
# Licensed under the MIT License.

param(
	$CertificateThumbprint = '601A8B683F791E51F647D34AD102C38DA4DDB65F'
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

trap
{
	throw $PSItem
}

$VersionNumberHex = '00010000'
$list = @(
	( [int32]::Parse($VersionNumberHex.Substring(0,4),[System.Globalization.NumberStyles]::HexNumber) + 0),
	( [int32]::Parse($VersionNumberHex.Substring(4,2),[System.Globalization.NumberStyles]::HexNumber) + 0),
	( [int32]::Parse($VersionNumberHex.Substring(6,2),[System.Globalization.NumberStyles]::HexNumber) + 0)
)

$Version = Join-String -Separator '.' -InputObject $list

Write-Output "Version is $Version from $VersionNumberNex"

foreach ($EDITION in 'Community', 'Professional')
{
	$VCVARSDIR = "${Env:ProgramFiles}\Microsoft Visual Studio\2022\$EDITION\VC\Auxiliary\Build"

	if ( Test-Path -LiteralPath $VCVARSDIR -PathType Container )
	{
		break
	}
}

$VCVARSARM = 'vcvarsarm.bat'
$VCVARSARM64 = 'vcvarsarm64.bat'
$VCVARSAMD64 = 'vcvars64.bat'
$VCVARSX86 = 'vcvars32.bat'
$VCVARSHOST = 'vcvars32.bat'

switch ($Env:PROCESSOR_ARCHITECTURE)
{
	'AMD64' {
		$VCVARSX86 = 'vcvarsamd64_x86.bat'
		$VCVARSARM = 'vcvarsamd64_arm.bat'
		$VCVARSARM64 = 'vcvarsamd64_arm64.bat'
		$VCVARSHOST = $VCVARSAMD64
	}
	'ARM64' {
		$VCVARSX86 = 'vcvarsarm64_x86.bat'
		$VCVARSARM = 'vcvarsarm64_arm.bat'
		$VCVARSAMD64 = 'vcvarsarm64_amd64.bat'
		$VCVARSHOST = $VCVARSARM64
	}
	'X86' {
		$VCVARSXARM64 = 'vcvarsx86_arm64.bat'
		$VCVARSARM = 'vcvarsx86_arm.bat'
		$VCVARSAMD64 = 'vcvarsx86_amd64.bat'
	}
	Default {
		throw "Unknown architecture $Env:PROCESSOR_ARCHITECTURE"
	}
}

$VCVARSARCH = @{'arm' = $VCVARSARM; 'arm64' = $VCVARSARM64; 'x86' = $VCVARSX86; 'x64' = $VCVARSAMD64}

$ARCHLIST = ( $VCVARSARCH.Keys | ForEach-Object {
	$VCVARS = $VCVARSARCH[$_];
	if ( Test-Path -LiteralPath "$VCVARSDIR/$VCVARS" -PathType Leaf )
	{
		$_
	}
} | Sort-Object )

$ARCHLIST | ForEach-Object {
	New-Object PSObject -Property @{
		Architecture=$_;
		Environment=$VCVARSARCH[$_]
	}
} | Format-Table -Property Architecture,'Environment'

foreach ($DIR in 'obj', 'bin')
{
	if (Test-Path -LiteralPath $DIR)
	{
		Remove-Item -LiteralPath $DIR -Force -Recurse
	}
}

$ARCHLIST | ForEach-Object {
	$ARCH = $_

	$VCVARS = ( '{0}\{1}' -f $VCVARSDIR, $VCVARSARCH[$ARCH] )

	$VersionStr4="$Version.0"
	$VersionInt4=$VersionStr4.Replace(".",",")

	switch ($ARCH)
	{
		'x86'   { $UpgradeCode7='0577E7CA-5ACE-42FA-AC23-4B57AE726F0F' ; $UpgradeCode1='8B32C2CD-B7AF-42B8-9915-A123FBA62A91' ; $IsWin64='no' ; $InstallerVersion='200' ; $ProgramFiles='ProgramFilesFolder' ; $SystemFolder='SystemFolder' }
		'x64'   { $UpgradeCode7='C3AE18AB-191D-4082-998C-7693A4B0CBB1' ; $UpgradeCode1='214EE2F8-EE8A-4FBA-A793-044A0D13343C' ; $IsWin64='yes' ; $InstallerVersion='200' ; $ProgramFiles='ProgramFiles64Folder' ; $SystemFolder='System64Folder' }
		'arm'   { $UpgradeCode7='5D2BAC57-FEA0-42C7-B8B2-1F420C438C7B' ; $UpgradeCode1='89FD68C3-6182-4F78-8AD2-47A582224DB4' ; $IsWin64='no' ; $InstallerVersion='500' ; $ProgramFiles='ProgramFilesFolder' ; $SystemFolder='SystemFolder' }
		'arm64' { $UpgradeCode7='95599786-8B24-4944-ABB8-BFA3D5E5E893' ; $UpgradeCode1='A82341CA-7BD4-4E58-92C1-8D31F9B69758' ; $IsWin64='yes' ; $InstallerVersion='500' ; $ProgramFiles='ProgramFiles64Folder' ; $SystemFolder='System64Folder' }
		defailt { throw "unknown $ARCH" }
	}

	$Description1="amsi.dll for WindowsPowerShell v1.0 $ARCH"
	$Description7="amsi.dll for PowerShell 7 $ARCH"

	@"
CALL "$VCVARS"
IF ERRORLEVEL 1 EXIT %ERRORLEVEL%
NMAKE /NOLOGO clean
IF ERRORLEVEL 1 EXIT %ERRORLEVEL%
NMAKE /NOLOGO DEPVERS_STR4="$VersionStr4" DEPVERS_INT4="$VersionInt4" CertificateThumbprint="$CertificateThumbprint" "bin\$ARCH\amsi.dll"
IF ERRORLEVEL 1 EXIT %ERRORLEVEL%
NMAKE /NOLOGO DEPVERS_STR4="$VersionStr4" DEPVERS_INT4="$VersionInt4" CertificateThumbprint="$CertificateThumbprint" AMSIMSI="PowerShell-7-amsi-$VersionStr4-$ARCH.msi" PRODUCTNAME="PowerShell 7 amsi" PACKAGEDESCRIPTION="$Description7" INSTALLERVERSION=$InstallerVersion ISWIN64=$IsWin64 NAMEDPARENTDIR=$ProgramFiles POWERSHELLDIR=PowerShell INSTALLLDIR=7 UPGRADECODE=$UpgradeCode7 PACKAGEPLATFORM=$ARCH msi
IF ERRORLEVEL 1 EXIT %ERRORLEVEL%
NMAKE /NOLOGO DEPVERS_STR4="$VersionStr4" DEPVERS_INT4="$VersionInt4" CertificateThumbprint="$CertificateThumbprint" AMSIMSI="WindowsPowerShell-amsi-$VersionStr4-$ARCH.msi" PRODUCTNAME="WindowsPowerShell v1.0 amsi" PACKAGEDESCRIPTION="$Description1" INSTALLERVERSION=$InstallerVersion ISWIN64=$IsWin64 NAMEDPARENTDIR=$SystemFolder POWERSHELLDIR=WindowsPowerShell INSTALLLDIR=v1.0 UPGRADECODE=$UpgradeCode1 PACKAGEPLATFORM=$ARCH msi
EXIT %ERRORLEVEL%
"@ | & "$env:COMSPEC"

	if ($LastExitCode -ne 0)
	{
		exit $LastExitCode
	}
}

$ARCHLIST | ForEach-Object {
	$ARCH = $_
	$VCVARS = ( '{0}\{1}' -f $VCVARSDIR, $VCVARSARCH[$ARCH] )
	$EXE = "bin\$ARCH\amsi.dll"

	$MACHINE = ( @"
@CALL "$VCVARS" > NUL:
IF ERRORLEVEL 1 EXIT %ERRORLEVEL%
dumpbin /headers $EXE
IF ERRORLEVEL 1 EXIT %ERRORLEVEL%
EXIT %ERRORLEVEL%
"@ | & "$env:COMSPEC" /nologo /Q | Select-String -Pattern " machine " )

	$MACHINE = $MACHINE.ToString().Trim()

	$MACHINE = $MACHINE.Substring($MACHINE.LastIndexOf(' ')+1)

	New-Object PSObject -Property @{
		Architecture=$ARCH;
		Executable=$EXE;
		Machine=$MACHINE;
		FileVersion=(Get-Item $EXE).VersionInfo.FileVersion;
		ProductVersion=(Get-Item $EXE).VersionInfo.ProductVersion;
		FileDescription=(Get-Item $EXE).VersionInfo.FileDescription
	}
} | Format-Table -Property Architecture, Executable, Machine, FileVersion, ProductVersion, FileDescription

if (Test-Path -LiteralPath "amsi-$Version.zip")
{
	Remove-Item  -LiteralPath "amsi-$Version.zip"
}

Push-Location 'bin'

try
{
	Compress-Archive -LiteralPath $ARCHLIST -DestinationPath "..\amsi-$Version.zip"
}
finally
{
	Pop-Location
}
