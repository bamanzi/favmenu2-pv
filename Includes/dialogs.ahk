#include dialogs\os_dialog.ahk
#include dialogs\explorer.ahk

#include dialogs\console.ahk
#include dialogs\cygwin.ahk
#include dialogs\msys.ahk

#include dialogs\total_commander.ahk
#include dialogs\free_commander.ahk
#include dialogs\xplorer2.ahk
#include dialogs\xyplorer.ahk
#include dialogs\double_commander.ahk

#include dialogs\gtk.ahk
#include dialogs\emacs.ahk
;; 7-Zip FM

; Explorer is seen as dialog if there is another app set as a file manager
; or as a File Manager if not. 
; If Explorer is current File Manager don't report it as a dialog.
;
FavMenu_DialogGetActive(hw=0)
{	
	global 
	local class, title

	WinGet, Favmenu_dlgHwnd, ID, A
	WinGetClass, class, ahk_id %Favmenu_dlgHwnd%
	WinGetTitle, title, ahk_id %Favmenu_dlgHwnd%
	
	if FavMenu_IsOpenSave( Favmenu_dlgHwnd )
			return 1
	
	if FavMenu_IsBrowseForFolder( Favmenu_dlgHwnd )
			return 1

	If (InStr(title, "MINGW32", true)>0)
	{
		FavMenu_dlgType := "Msys"
		return 1
	}

	if (class = "ConsoleWindowClass") or (class = "VirtualConsoleClass") or (class = "Console_2_main")
	{
		FavMenu_dlgType	 := "Console"
		return 1
	}

	if (class = "ExploreWClass") or (class = "CabinetWClass")
	{
		FavMenu_GetExplorerInput()
		FavMenu_dlgType := "Explorer"
		return 1
	}

	if (class = "TTOTAL_CMD")
	{
		FavMenu_dlgType := "TC"
		return 1
	}
	
	If (class = "TfcForm") Or (class="FreeCommanderXE.SingleInst.1")
	{
		FavMenu_dlgType := "FreeCommander"
		return 1
	}	
	
	if ( (class = "Emacs") Or (class = "MicroEmacsClass") Or (class = "XEmacs" ) )
	{
		FavMenu_dlgType := "Emacs"
		return 1
	}
	
	If (class = "mintty") Or (SubStr(class, 1, 4) = "rxvt")
	{
		FavMenu_dlgType := "Cygwin"
		return 1
	}
	
	If (class = "gdkWindowToplevel")
	{
		FavMenu_dlgType := "GTK"
		return 1
	}
	
	If (class = "ATL:ExplorerFrame")
	{
		FavMenu_dlgType := "Xplorer2"
		return 1
	}	

	;; FIXME: add support for non-free version
	;; FIXME: this relies on the title bar template, by default it's '<path> - <app> <ver>'
	If (class = "ThunderRT6FormDC") and ((title contains " - XYplorerFree ") or (title contains " - XYplorer "))
	{
		FavMenu_dlgType := "XYplorer"
		return 1
	}

	If (class = "Window") and ("Double Commander 0"==substr(title, 1, StrLen("Double Commander ")))
	{
		FavMenu_dlgType := "DoubleCommander"
		return 1
	}

	Favmenu_dlgType := "System"
	Favmenu_dlgHwnd := 0
	return 0
}


FavMenu_DialogGetPath()
{
	global
	OutputDebug,FavMenu_DialogGetPath called with Favmenu_dlgType = %Favmenu_dlgType%`n

	if Favmenu_dlgType = TC
		return Favmenu_DialogGetPath_TC()

	if Favmenu_dlgType = Explorer
		return Favmenu_DialogGetPath_Explorer()

	if Favmenu_dlgType = OpenSave
		return Favmenu_DialogGetPath_OS()
	
	if Favmenu_dlgType = BFF
		return Favmenu_DialogGetPath_BFF()

	if FavMenu_dlgType = Msys
		return FavMenu_DialogGetPath_Msys()

	if FavMenu_dlgType = Cygwin
		return FavMenu_DialogGetPath_Cygwin()
	
	if Favmenu_dlgType = Console
		return Favmenu_DialogGetPath_Console()
	
	if Favmenu_dlgType = Emacs
		return Favmenu_DialogGetPath_Emacs()

	If FavMenu_dlgType = FreeCommander
		return FavMenu_DialogGetPath_FreeCommander()
	
	if Favmenu_dlgType = Xplorer2
		return FavMenu_DialogGetPath_Xplorer2()

	if Favmenu_dlgType = XYplorer
		return FavMenu_DialogGetPath_XYplorer()

	if Favmenu_dlgType = DoubleCommander
		return FavMenu_DialogGetPath_DoubleCommander()

	return Favmenu_DialogGetPath_fromTitle()
}

FavMenu_DialogSetPath(path, bTab = false)
{
	global FavMenu_dlgType
	OutputDebug,FavMenu_DialogSetPath called with Favmenu_dlgType = %Favmenu_dlgType%`n

	if FavMenu_dlgType = TC
		FavMenu_DialogSetPath_TC(path, bTab)

	if FavMenu_dlgType contains OpenSave,Office03
		FavMenu_DialogSetPath_OS(path)	
	
	if FavMenu_dlgType = BFF
		FavMenu_DialogSetPath_BFF(path)

	if FavMenu_dlgType = Explorer
		FavMenu_DialogSetPath_Explorer(path, bTab)
	
	if FavMenu_dlgType = Msys
		FavMenu_DialogSetPath_Msys(path, bTab)

	if FavMenu_dlgType = Cygwin
		FavMenu_DialogSetPath_Cygwin(path)
	
	if FavMenu_dlgType = Console
		FavMenu_DialogSetPath_Console(path, bTab)

	if FavMenu_dlgType = Emacs
		FavMenu_DialogSetPath_Emacs(path)
	
	if FavMenu_dlgType = GTK
		FavMenu_DialogSetPath_GTK(path)

	If FavMenu_dlgType = FreeCommander
		FavMenu_DialogSetPath_FreeCommander(path, bTab)

	if FavMenu_dlgType = Xplorer2
		FavMenu_DialogSetPath_Xplorer2(path, bTab)

	if FavMenu_dlgType = XYplorer
		FavMenu_DialogSetPath_XYplorer(path, bTab)

	if FavMenu_dlgType = DoubleCommander
		FavMenu_DialogSetPath_DoubleCommander(path, bTab)
}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_fromTitle()
{
	;;for other applications/dialogs, try to parse title
	Local title
	WinGetActiveTitle, title
	OutputDebug, try to parse directory from title: %title%`n
	If title contains :\,\\
	{	
		local fstart, fend1, fend2, fend3, curDir
		fstart := InStr(title, ":\") -1
		if fstart <=0
		{
			fstart := InStr(title, "\\")
			if fstart <=0
				return
		}
		
		fend1 := InStr(title, " - ", fstart + 2) ;; mostly used
		fend2 := InStr(title, " * ", fstart + 2) ;; SciTE (SciTE4AHK)
		fend2 := InStr(title, "]",   fstart + 2)
		
		local fname1, fname2, fname3, fname4
		fname1 := SubStr(title, fstart, fend1 - fstart)
		fname2 := SubStr(title, fstart, fend2 - fstart)
		fname3 := SubStr(title, fstart, fend2 - fstart)
		fname4 := SubStr(title, fstart)
		
		OutputDebug `nDialogGetPath_FromTitle: fname1=%fname1%`nfname2=%fname2%`nfname3=%fname3%`n
		If FileExist(fname1) 
			curDir := fname1
		else if FileExist(fname2)
			curDir := fname2
		else if FileExist(fname3)
			curDir := fname3
		else if FileExist(fname4)
			curDir := fname4
		else
			return
		
		;; if it is not a directory
		If InStr(FileExist(curDir), "D")<=0
		{
			Splitpath,curDir,,dirpart
			;; add a trailing slash as SplitPath would return 'd:' for file 'd:\test.txt'
			if (StrLen(dirpart) = 2)
				dirpart = %dirpart%\
			return dirpart
		}
		else
			return curDir
	}
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
