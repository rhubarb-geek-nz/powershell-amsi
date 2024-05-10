#!/usr/bin/env pwsh
# Copyright (c) 2024 Roger Brown.
# Licensed under the MIT License.

trap
{
	throw $PSItem
}

$ErrorActionPreference = 'Stop'

try
{
	$progressParams = @{
		Activity = "Benchmark timing"
		Status = "In progress"
		PercentComplete = 0
		CurrentOperation = 'ConvertTo-Base64String'
	}
 
	Write-Progress @progressParams

	Get-Command -Noun ('Array','Base64','Base64String','Reflection')

	$bytes = new-object byte[] -ArgumentList @(,200554320)

	$random = new-object Random

	$random.NextBytes($bytes)

	[string]$base64 = @(,$bytes) | ConvertTo-Base64String
	$bytes = $null

	$T0 = Get-Date

	$progressParams.PercentComplete = 20
	$progressParams.CurrentOperation = 'ConvertFrom-Base64String'
	Write-Progress @progressParams

	$bytes = $base64 | ConvertFrom-Base64String
	$bytes = $null

	$T1 = Get-Date

	$progressParams.PercentComplete = 40
	$progressParams.CurrentOperation = '[System.Convert]::FromBase64String'
	Write-Progress @progressParams

	$bytes = [System.Convert]::FromBase64String($base64)
	$bytes = $null

	$T2 = Get-Date

	$progressParams.PercentComplete = 60
	$progressParams.CurrentOperation = 'Invoke-Reflection'
	Write-Progress @progressParams

	$bytes = Invoke-Reflection -Method FromBase64String -Type ([System.Convert]) -ArgumentList @(,$base64)
	$bytes = $null

	$T3 = Get-Date

	$progressParams.PercentComplete = 80
	$progressParams.CurrentOperation = 'Type.GetMethod().Invoke()'
	Write-Progress @progressParams

	$getMethod=([System.Convert]).GetType().GetMethod('GetMethod',[Type[]](([string],([Type[]]))))
	$fromBase64String=$getMethod.Invoke(([System.Convert]),[object[]]('FromBase64String', [Type[]](,([string]))))
	$bytes = $fromBase64String.Invoke($Null,[object[]](,$base64))
	$bytes = $null

	$T4 = Get-Date

	$progressParams.PercentComplete = 100
	$progressParams.CurrentOperation = 'ConvertFrom-Base64 | Join-Array'
	Write-Progress @progressParams

	$bytes = $base64 | ConvertFrom-Base64 | Join-Array -Type ([byte])
	$bytes = $null

	$T5 = Get-Date
}
finally
{
	Write-Progress -Completed -Activity "Completed"
}

@(
	[pscustomobject]@{
		TestCase = 'ConvertFrom-Base64String'
		Duration = [int]($T1-$T0).TotalMilliseconds
	},
	[pscustomobject]@{
		TestCase = '[System.Convert]::FromBase64String()'
		Duration = [int]($T2-$T1).TotalMilliseconds
	},
	[pscustomobject]@{
		TestCase = 'Invoke-Reflection'
		Duration = [int]($T3-$T2).TotalMilliseconds
	},
	[pscustomobject]@{
		TestCase = 'Type.GetMethod().Invoke()'
		Duration = [int]($T4-$T3).TotalMilliseconds
	},
	[pscustomobject]@{
		TestCase = 'ConvertFrom-Base64 | Join-Array'
		Duration = [int]($T5-$T4).TotalMilliseconds
	}
) | Format-Table

$PSVersionTable
