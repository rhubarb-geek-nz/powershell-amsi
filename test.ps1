# Copyright (c) 2023 Roger Brown.
# Licensed under the MIT License.
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
