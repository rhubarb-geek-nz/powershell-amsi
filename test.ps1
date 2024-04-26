# Copyright (c) 2023 Roger Brown.
# Licensed under the MIT License.
$env:__PSDumpAMSILogContent='1'

trap
{
	throw $PSItem
}

$ErrorActionPreference = 'Stop'

Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Security;
namespace RhubarbGeekNz.PowerShellAmsi
{
	public class Librarian
	{
		[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
		public static extern IntPtr GetModuleHandleW(string lpModuleName);

		[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
		public static extern int GetModuleFileNameW(IntPtr mod,char [] lpModuleName,int size);

		public string GetModuleFileName(IntPtr mod)
		{
			char [] buf=new char[512];
			int i=GetModuleFileNameW(mod,buf,buf.Length-1);
			return new string(buf,0,i);
		}
	}
}
'@

$dll = New-Object RhubarbGeekNz.PowerShellAmsi.Librarian

$mod = $dll::GetModuleHandleW('amsi')

if ($mod -and ($mod -ne 0))
{
	$file = $dll.GetModuleFileName($mod)
	$app = $dll.GetModuleFileName(0)

	$app,$file | ForEach-Object {
		Get-AuthenticodeSignature -FilePath $_
	} | ForEach-Object {
		$info=(Get-Item -LiteralPath $_.Path).VersionInfo
		New-Object PSObject -Property @{
			SignerCertificate=$_.SignerCertificate.Thumbprint;
			StatusMessage=$_.StatusMessage;
			Path=$_.Path;
			FileVersion=$info.FileVersion
		}
	} | Format-Table -Property Path,FileVersion,SignerCertificate,StatusMessage
}
else
{
	Write-Warning 'amsi module not loaded'
}
