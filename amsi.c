/***********************************
 * Copyright (c) 2024 Roger Brown.
 * Licensed under the MIT License.
 ****/

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <amsi.h>

HRESULT APIENTRY AmsiInitialize(LPCWSTR app,HAMSICONTEXT *amsiContext)
{
    *amsiContext = NULL;
    return S_OK;
}

void APIENTRY AmsiCloseSession(HAMSICONTEXT amsiContext,HAMSISESSION amsiSession)
{
}

HRESULT APIENTRY AmsiNotifyOperation(HAMSICONTEXT amsiContext,PVOID buffer,ULONG length,LPCWSTR contentName,AMSI_RESULT* result)
{
    *result = AMSI_RESULT_NOT_DETECTED;
    return S_OK;
}

HRESULT APIENTRY AmsiOpenSession(HAMSICONTEXT amsiContext,HAMSISESSION* amsiSession)
{
    *amsiSession = NULL;
    return S_OK;
}

HRESULT APIENTRY AmsiScanBuffer(HAMSICONTEXT amsiContext,PVOID buffer,ULONG length,LPCWSTR contentName,HAMSISESSION amsiSession,AMSI_RESULT* result)
{
    *result = AMSI_RESULT_NOT_DETECTED;
    return S_OK;
}

HRESULT APIENTRY AmsiScanString(HAMSICONTEXT amsiContext,LPCWSTR string,LPCWSTR contentName,HAMSISESSION amsiSession,AMSI_RESULT* result)
{
    *result = AMSI_RESULT_NOT_DETECTED;
    return S_OK;
}

void APIENTRY AmsiUninitialize(HAMSICONTEXT amsiContext)
{
}

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        DisableThreadLibraryCalls(hModule);
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
