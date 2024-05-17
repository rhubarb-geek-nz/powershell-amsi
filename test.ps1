#!/usr/bin/env pwsh
# Copyright (c) 2024 Roger Brown.
# Licensed under the MIT License.

Param(
	[string]$Command=$null
)

$env:__PSDumpAMSILogContent='1'

trap
{
	throw $PSItem
}

$ErrorActionPreference = 'Stop'

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

if ($Command)
{
	$Found = $True

	try
	{
		Get-Command -Name $Command
	}
	catch
	{
		$Found = $False
	}

	if ($Found)
	{
		throw "$Command was found as a command"
	}

	$ScriptContainedMaliciousContent = $False
	$FullyQualifiedErrorId = $Null

	try
	{
		Invoke-Expression -Command $Command
	}
	catch
	{
		$FullyQualifiedErrorId = $PSItem.FullyQualifiedErrorId
		$ScriptContainedMaliciousContent = ($FullyQualifiedErrorId -Split ',')[0] -Eq 'ScriptContainedMaliciousContent'
	}

	[pscustomobject]@{
		Command = $Command
		ScriptContainedMaliciousContent = $ScriptContainedMaliciousContent
		FullyQualifiedErrorId = $FullyQualifiedErrorId
	} | Format-Table
}
