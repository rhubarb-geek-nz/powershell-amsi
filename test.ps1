# Copyright (c) 2023 Roger Brown.
# Licensed under the MIT License.
$env:__PSDumpAMSILogContent='1'

trap
{
	throw $PSItem
}

$ErrorActionPreference = 'Stop'

$PSVersionTable

[System.Diagnostics.Process]::GetCurrentProcess().Modules | ForEach-Object {
		if ($_.ModuleName.EndsWith('.EXE',[System.StringComparison]::CurrentCultureIgnoreCase) -or $_.ModuleName -eq 'AMSI.DLL') {
			Get-AuthenticodeSignature -FilePath $_.FileName
		}
	} | ForEach-Object {
		$info=(Get-Item -LiteralPath $_.Path).VersionInfo
		New-Object PSObject -Property @{
			SignerCertificate=$_.SignerCertificate.Thumbprint;
			StatusMessage=$_.StatusMessage;
			Path=$_.Path;
			FileVersion=$info.FileVersion
		}
	} | Format-Table -Property Path,FileVersion,SignerCertificate,StatusMessage

$Name = 'Invoke'+'-'+'Mimi'+'katz'

$Found = $True

try
{
	Get-Command -Name $Name
}
catch
{
	$Found = $False
}

if ($Found)
{
	throw "$Name was found as a command"
}

$ScriptContainedMaliciousContent = $False
$FullyQualifiedErrorId = $Null

try
{
	Invoke-Expression -Command $Name
}
catch
{
	$FullyQualifiedErrorId = $PSItem.FullyQualifiedErrorId
	$ScriptContainedMaliciousContent = ($FullyQualifiedErrorId -Split ',')[0] -Eq 'ScriptContainedMaliciousContent'
}

[pscustomobject]@{
	Name = $Name
	ScriptContainedMaliciousContent = $ScriptContainedMaliciousContent
	FullyQualifiedErrorId = $FullyQualifiedErrorId
}
