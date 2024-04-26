# rhubarb-geek-nz/powershell-amsi

Goal here is to install an inert `amsi.dll` so that PowerShell is not broadcasting internal variable values.

## Introduction

PowerShell uses the `amsi.dll` to scan scripts and log method invocations. The [test.ps1](test.ps1) tool provided will show you the binaries.

Run the script from a new pwsh.exe to see the full logging.

```
D:\github\powershell-amsi>pwsh test.ps1

=== Amsi notification report content ===
<RhubarbGeekNz.PowerShellAmsi.Librarian>.GetModuleHandleW(<amsi>)
=== Amsi notification report success: True ===

=== Amsi notification report content ===
<RhubarbGeekNz.PowerShellAmsi.Librarian>.GetModuleFileName(<140723967754240>)
=== Amsi notification report success: True ===

=== Amsi notification report content ===
<RhubarbGeekNz.PowerShellAmsi.Librarian>.GetModuleFileName(<0>)
=== Amsi notification report success: True ===

=== Amsi notification report content ===
<System.Diagnostics.FileVersionInfo>.GetVersionInfo(<C:\Program Files\PowerShell\7\pwsh.exe>)
=== Amsi notification report success: True ===


=== Amsi notification report content ===
<System.Diagnostics.FileVersionInfo>.GetVersionInfo(<C:\WINDOWS\SYSTEM32\amsi.dll>)
=== Amsi notification report success: True ===
Path                                   FileVersion                         SignerCertificate                        StatusMessage
----                                   -----------                         -----------------                        -------------
C:\Program Files\PowerShell\7\pwsh.exe 7.4.2.500                           F9A7CF9FBE13BAC767F4781061332DA6E8B4E0EE Signature verified.
C:\WINDOWS\SYSTEM32\amsi.dll           10.0.22621.1 (WinBuild.160101.0800) D8FB0CC66A08061B42D46D03546F0D42CBC49B7C Signature verified.
```

## After installation

With default windows path searching, the application directory is searched first.

```
Path                                   FileVersion SignerCertificate                        StatusMessage
----                                   ----------- -----------------                        -------------
C:\Program Files\PowerShell\7\pwsh.exe 7.4.2.500   F9A7CF9FBE13BAC767F4781061332DA6E8B4E0EE Signature verified.
C:\Program Files\PowerShell\7\amsi.dll 1.0.0.0     601A8B683F791E51F647D34AD102C38DA4DDB65F Signature verified.
```

## Build

Build with [package.ps1](package.ps1). This will enumerate through the installed Visual Studio build environments to build multiple versions. WiX is used to create the MSI files.

```
Architecture Executable         Machine FileVersion ProductVersion FileDescription
------------ ----------         ------- ----------- -------------- ---------------
arm          bin\arm\amsi.dll   (ARM)   1.0.0.0     1.0.0.0        inert amsi library
arm64        bin\arm64\amsi.dll (ARM64) 1.0.0.0     1.0.0.0        inert amsi library
x64          bin\x64\amsi.dll   (x64)   1.0.0.0     1.0.0.0        inert amsi library
x86          bin\x86\amsi.dll   (x86)   1.0.0.0     1.0.0.0        inert amsi library
```

## Code changes

If you wanted to log to stderr you could change the [amsi.c](amsi.c) code, for example

```
HRESULT APIENTRY AmsiNotifyOperation(HAMSICONTEXT amsiContext,PVOID buffer,ULONG length,LPCWSTR contentName,AMSI_RESULT* result)
{
    HANDLE h = GetStdHandle(STD_ERROR_HANDLE);

    if (h != INVALID_HANDLE_VALUE)
    {
        DWORD dw = 0;
        WriteFile(h, buffer, length, &dw, NULL);
    }

    *result = AMSI_RESULT_NOT_DETECTED;
    return S_OK;
}
```

## WindowsPowerShell

Although the WindowsPowerShell version of the MSI does install the replacement `amsi.dll` in the correct location, `powershell.exe` continues to use the original one.
