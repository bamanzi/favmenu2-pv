FavMenu_ExpandEnvVars(ppath)
{
	VarSetCapacity(dest, 2000) 
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int") 
	return dest
}

FavMenu_GetSFLabel( sFolder )
{
	if (sFolder = "My Documents")
		return	Favmenu_GetResString("{450D8FBA-AD25-11D0-98A8-0800361B1103}")
	
	if (sFolder = "My Computer")
		return	Favmenu_GetResString("{20D04FE0-3AEA-1069-A2D8-08002B30309D}")

	if (sFolder = "My Network Places" )
		return	Favmenu_GetResString("{208D2C60-3AEA-1069-A2D7-08002B30309D}")
}

;--------------------------------------------------------------------------

FavMenu_GetResString( p_clsid )
{
	key = SOFTWARE\Classes\CLSID\%p_clsid%
	RegRead res, HKEY_LOCAL_MACHINE, %key%, LocalizedString
	
;get dll and resource id 
	StringGetPos idx, res, -, R
    StringMid, resID, res, idx+2, 256
	StringMid, resDll, res, 2, idx - 2
	resDll := FavMenu_ExpandEnvVars(resDll)
	
;get string from resource
	VarSetCapacity(buf, 256)
	hDll := DllCall("LoadLibrary", "str", resDll)
	Result := DllCall("LoadString", "uint", hDll, "uint", resID, "str", buf, "int", 128)

	return buf
}

;------------------------------------------------------------------------------------------------
; Iterate through controls with the same class, find the one with ctrlID and return its handle
; Used for finding a specific control on a dialog

FavMenu_FindWindowExID(dlg, className, ctrlId)
{
	local ctrl, id

	ctrl = 0
	Loop
	{
		ctrl := DllCall("FindWindowEx", "uint", dlg, "uint", ctrl, "str", className, "uint", 0 )
		if (ctrlId = "0")
		{
			return ctrl
		}

		if (ctrl != "0")
		{
			id := DllCall( "GetDlgCtrlID", "uint", ctrl )
			if (id = ctrlId) 
				return ctrl				
		}
		else 
			return 0
	}
}

;------------------------------------------------------------------------------------------------
; Some API functions require a WCHAR string. 
;
Favmenu_GetUnicodeString(ByRef @unicodeString, _ansiString) 
{ 
   local len 

   len := StrLen(_ansiString) 
   VarSetCapacity(@unicodeString, len * 2 + 1, 0) 

   ; http://msdn.microsoft.com/library/default.asp?url=/library/en-us/intl/unicode_17si.asp 
   DllCall("MultiByteToWideChar" 
         , "UInt", 0             ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001 
         , "UInt", 0             ; dwFlags 
         , "Str", _ansiString    ; LPSTR lpMultiByteStr 
         , "Int", len            ; cbMultiByte: -1=null terminated 
         , "UInt", &@unicodeString ; LPCWSTR lpWideCharStr 
         , "Int", len)           ; cchWideChar: 0 to get required size 
} 

;------------------------------------------------------------------------------------------------
; Some API functions return a WCHAR string. 
;
FavMenu_GetAnsiStringFromUnicodePointer(_unicodeStringPt) 
{ 
   local len, ansiString 

   len := DllCall("lstrlenW", "UInt", _unicodeStringPt) 
   VarSetCapacity(ansiString, len, 0) 

   DllCall("WideCharToMultiByte" 
         , "UInt", 0           ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001 
         , "UInt", 0           ; dwFlags 
         , "UInt", _unicodeStringPt ; LPCWSTR lpWideCharStr 
         , "Int", len          ; cchWideChar: size in WCHAR values, -1=null terminated 
         , "Str", ansiString   ; LPSTR lpMultiByteStr 
         , "Int", len          ; cbMultiByte: 0 to get required size 
         , "UInt", 0           ; LPCSTR lpDefaultChar 
         , "UInt", 0)          ; LPBOOL lpUsedDefaultChar 

   Return ansiString 
}



;---------------------------------------------
; Open remote buffer
;
; ARGUMENTS: p_handle	- HWND of buffer host
;			 p_size		- Size of the buffer
;
; Returns	buffer handle (>0)
;			-1 if unable to open process
;			-2 if unable to get memory
;--------------------------------------------
RemoteBuf_Open(p_handle, p_size)
{
	global
	local proc_hwnd, bufAdr, pid

	
	WinGet, pid, PID, ahk_id %p_handle%
	proc_hwnd := DllCall( "OpenProcess"
                         , "uint", 0x38				; PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE (0x0020)
                         , "int", false 
                         , "uint", pid ) 

	if proc_hwnd = 0
		return -1
		
	bufAdr	:= DllCall( "VirtualAllocEx" 
                        , "uint", proc_hwnd
                        , "uint", 0 
                        , "uint", p_size			; SIZE
                        , "uint", 0x1000            ; MEM_COMMIT 
                        , "uint", 0x4 )				; PAGE_READWRITE 
	
	if bufAdr = 
		return -2

	RemoteBuf_idx += 1
	RemoteBuf_%RemoteBuf_idx%_handle  := proc_hwnd
	RemoteBuf_%RemoteBuf_idx%_size	  := p_size
	RemoteBuf_%RemoteBuf_idx%_adr	  := bufAdr

	return RemoteBuf_idx
}

;----------------------------------------------------
; Close remote buffer.
;----------------------------------------------------
RemoteBuf_Close(p_bufHandle)
{
	global
	local handle, adr

	handle	:= RemoteBuf_%p_bufHandle%_handle
	adr		:= RemoteBuf_%p_bufHandle%_adr

	if handle = 0
		return 0

    result := DllCall( "VirtualFreeEx" 
                     , "uint", handle
                     , "uint", adr
                     , "uint", 0 
                     , "uint", 0x8000 )				; MEM_RELEASE 
	

	DllCall( "CloseHandle", "uint", handle )

	RemoteBuf_%p_bufHandle%_adr		 = 
	RemoteBuf_%RemoteBuf_idx%_size	 =
	RemoteBuf_%RemoteBuf_idx%_handle =

	return result
}
;----------------------------------------------------
; Read remote buffer and return buffer
;----------------------------------------------------
RemoteBuf_Read(p_bufHandle, byref p_localBuf, p_size, p_offset = 0)
{
	global
	local handle, adr, size, localBuf

	handle	:= RemoteBuf_%p_bufHandle%_handle
	adr		:= RemoteBuf_%p_bufHandle%_adr
	size	:= RemoteBuf_%p_bufHandle%_size


	if (handle = 0) or (adr = 0) or (offset >= size)
		return -1

    result := DllCall( "ReadProcessMemory" 
                  , "uint", handle
                  , "uint", adr + p_offset
                  , "uint", &p_localBuf
                  , "uint", p_size
                  , "uint", 0 ) 
	
	return result
}

;----------------------------------------------------
; Write to remote buffer, local buffer p_local.
;----------------------------------------------------
RemoteBuf_Write(p_bufHandle, byref p_local, p_size, p_offset=0)
{
	global
	local handle, adr, size

	handle	:= RemoteBuf_%p_bufHandle%_handle
	adr		:= RemoteBuf_%p_bufHandle%_adr
	size	:= RemoteBuf_%p_bufHandle%_size
	

	if (handle = 0) or (adr = 0) or (offset >= size)
		return -1

	result  := DllCall( "WriteProcessMemory"
						,"uint", handle
						,"uint", adr + p_offset
						,"uint", &p_local
						,"uint", p_size
						,"uint", 0 )

	return result
}


RemoteBuf_GetAdr(p_handle) 
{
	global
	return 	RemoteBuf_%p_handle%_adr
}

RemoteBuf_GetSize(p_handle) 
{
	global
	return 	RemoteBuf_%p_handle%_size
}
