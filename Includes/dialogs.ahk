; Explorer is seen as dialog if there is another app set as a file manager
; or as a File Manager if not. 
; If Explorer is current File Manager don't report it as a dialog.
;
FavMenu_DialogGetActive(hw=0)
{	
	global 
	local class

	WinGet, Favmenu_dlgHwnd, ID, A
	WinGetClass, class, ahk_id %Favmenu_dlgHwnd%
	
	if FavMenu_IsOpenSave( Favmenu_dlgHwnd )
			return 1
	
	if FavMenu_IsBrowseForFolder( Favmenu_dlgHwnd )
			return 1

	if (class = "ConsoleWindowClass")
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
	
	if ( (class = "Emacs") Or (class = "MicroEmacsClass") Or (class = "XEmacs" ) )
	{
		FavMenu_dlgType := "Emacs"
		return 1
	}

	Favmenu_dlgType := "System"
	Favmenu_dlgHwnd := 0
	return 0
}

;------------------------------------------------------------------------------------------------

FavMenu_GetExplorerInput()
{
	global
	Favmenu_dlgInput := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "WorkerW", 0) 
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ReBarWindow32", 0) 
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBoxEx32", 0)
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBox", 0)
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "Edit", 0)
}

;------------------------------------------------------------------------------------------------

FavMenu_IsBrowseForFolder( dlg )
{
	global FavMenu_dlgInput, FavMenu_dlgType

	;check for old browse for folder dialog first
	static1 := FavMenu_FindWindowExID(dlg, "Static", 14146)
	static2 := FavMenu_FindWindowExID(dlg, "Static", 14147)
	tree	:= FavMenu_FindWindowExID(dlg, "SysTreeView32", 14145)
	bOK		:= FavMenu_FindWindowExID(dlg, "Button", 1)
	bCancel := FavMenu_FindWindowExID(dlg, "Button", 2)
	
	if static1 * static2 * tree * bOK * bCancel = 0
	{
		;check for new browse for folder dialog
		ctrl := FavMenu_FindWindowExID(dlg, "SHBrowseForFolder ShellNameSpace Control", 0)
		tree := FavMenu_FindWindowExID(ctrl, "SysTreeView32", 100)

		if tree*ctrl  = 0
			return 0
	}

	FavMenu_dlgInput := tree
	FavMenu_dlgType	 := "BFF"

	return 1
}

;------------------------------------------------------------------------------------------------

FavMenu_IsOpenSave(dlg)
{
	global FavMenu_dlgInput, FavMenu_dlgType
	
	FavMenu_dlgType =

	toolbar := FavMenu_FindWindowExID(dlg, "ToolbarWindow32", 0x440)   ;windows XP
	if (toolbar = "0")
	 toolbar := FavMenu_FindWindowExID(dlg, "ToolbarWindow32", 0x001)  ;windows 2k
	 
	combo  := FavMenu_FindWindowExID(dlg, "ComboBoxEx32", 0x47C) ; comboboxex field
	button := FavMenu_FindWindowExID(dlg, "Button", 0x001)		; second button
	 
	edit := FavMenu_FindWindowExID(dlg, "Edit", 0x480)			; edit field
	 
	if (toolbar && (combo || edit) && button) 
	{
		FavMenu_dlgInput	:= combo + edit
		FavMenu_dlgType		:= "OpenSave"
		return 1
	}

	return FavMenu_IsOffice03(dlg)
}

;------------------------------------------------------------------------------------------------

FavMenu_IsOffice03(dlg)
{
	global FavMenu_dlgInput, FavMenu_dlgType, FavMenu_cOffice

	WinGetClass cls, ahk_id %dlg%

	FavMenu_dlgIsOffice := false
	if cls contains %FavMenu_cOffice%
	{
		snake := FavMenu_FindWindowExID(dlg, "Snake List", 0)
		FavMenu_dlgInput := FavMenu_FindWindowExID(dlg, "RichEdit20W", 54)

		if ! (snake && FavMenu_dlgInput)
			return 0	
			
		FavMenu_dlgType	:= "Office03"
		return 1
	}

	return 0
}
 
;--------------------------------------------------------------------------

FavMenu_DialogGetPath()
{
	global

	if Favmenu_dlgType = TC
		return Favmenu_DialogGetPath_TC()

	if Favmenu_dlgType = Explorer
		return Favmenu_DialogGetPath_Explorer()

	if Favmenu_dlgType = OpenSave
		return Favmenu_DialogGetPath_OS()
	
	if Favmenu_dlgType = BFF
		return Favmenu_DialogGetPath_BFF()
	
	if Favmenu_dlgType = Console
		return Favmenu_DialogGetPath_Console()
	
	if Favmenu_dlgType = Emacs
		return Favmenu_DialogGetPath_Emacs()

}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_TC()
{
	curDir := FavMenu_GetCurrentTCDir()
	StringGetPos idx, curDir, \, R

	if (idx != -1) && StrLen(curDir) > 3
			StringMid name, curDir, idx+2, 256
	else	StringMid name, curDir, 1, 2

	return curDir
}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_Explorer()
{
	global Favmenu_dlgHwnd

	tv := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "BaseBar", 0) 
	tv := Favmenu_FindWindowExID(tv, "ReBarWindow32", 0) 
	tv := Favmenu_FindWindowExID(tv, "SysTreeView32", 100)

	TV_Initialise( FavMenu_dlgHWND, tv )
	return TV_GetPath()
}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_Console()
{
	SendInput {HOME}echo {END}>c:\favmenu_contmp&echo `%cd`%>>c:\favmenu_contmp{ENTER}
	Sleep 100

	FileReadLine prev, c:\favmenu_contmp, 1
	FileReadLine curDir, c:\favmenu_contmp, 2
	FileDelete c:\favmenu_contmp
	
	if (prev != "ECHO is on.") && (prev != "ECHO 处于打开状态。")
		SendInput %prev%
	
	return curDir
}

Favmenu_DialogGetPath_Emacs()
{
	;;TODO: ensure compatibility of XEmacs
  
	WinGetActiveTitle,Title

	;; cancel current thing if any
	SendInput ^g
	;; find-file
	SendInput ^x^f
	;; begging-of-line
	SendInput ^a

	;; set-mark
	if InStr(Title, " MicroEmacs")>1
	{
		;;tested on MicroEmacs-jasspa
		SendInput {Esc}{Space}
	}
	Else
	{
		SendInput ^+2  ;; C-@
	}
	;; move-end-of-line
	SendInput ^e

	;; kill-ring-save
	SendInput !w
	Sleep 100

	;; cancel find-file
	SendInput ^g

	resultP = %clipboard%
	;; OutputDebug,Clipboard content: %clipboard%
	StringReplace,curDir,resultP,/,\,All
	;; OutputDebug,Favmenu_DialogSetPath_Emacs returns: %curDir%
	return curDir
}
;--------------------------------------------------------------------------

Favmenu_DialogGetPath_BFF()
{
	global

	TV_Initialise( FavMenu_dlgHWND, FavMenu_dlgInput )
	return TV_GetPath()
}

FavMenu_DialogGetPath_OS()
{
	global Favmenu_dlgHwnd

	WM_USER = 0x400 
	CDM_FIRST := WM_USER + 100
	CDM_GETFOLDERPATH := CDM_FIRST + 0x0002

	bufID := RemoteBuf_Open(Favmenu_dlgHwnd, 256)
	adr := RemoteBuf_GetAdr(bufID)
	SendMessage CDM_GETFOLDERPATH, 256, adr,, ahk_id %Favmenu_dlgHwnd%
	textSize := errorlevel
	if (textSize <= 0)
		return

	VarSetCapacity(buf, 256, 0)
	RemoteBuf_Read(bufID, buf, 256)
	RemoteBuf_Close(bufID)

	VarSetCapacity(ansiString, textSize, 0)
	
	;Check if Windows returned unicode string. Sine drive letter is first char, it will be ANSI
	; so unicode can be check by comparing next char to 0
	if *(&buf+1) = 0
			return FavMenu_GetAnsiStringFromUnicodePointer(&buf)
	else	return buf
	
}

;--------------------------------------------------------------------------
FavMenu_DialogSetPath(path, bTab = false)
{
	global FavMenu_dlgType

	if FavMenu_dlgType = TC
		FavMenu_DialogSetPath_TC(path, bTab)

	if FavMenu_dlgType contains OpenSave,Office03
		FavMenu_DialogSetPath_OS(path)	
	
	if FavMenu_dlgType = BFF
		FavMenu_DialogSetPath_BFF(path)
	
	if FavMenu_dlgType = Console
		FavMenu_DialogSetPath_Console(path, bTab)

	if FavMenu_dlgType = Emacs
		FavMenu_DialogSetPath_Emacs(path)
	
	if FavMenu_dlgType = Explorer
		FavMenu_DialogSetPath_Explorer(path, bTab)
}

;--------------------------------------------------------------------------
FavMenu_DialogSetPath_TC(path, bTab = false)
{
	global 

	if (bTab)
		FavMenu_SendTCCommand(cm_OpenNewTab)
	
	WinActivate ahk_class TTOTAL_CMD

	FavMenu_SendTCCommand(cm_editpath)
	SendRaw, %path%
	Send, {ENTER}
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_Explorer(path, bTab = false)
{
	global
	
	if (Favmenu_dlgInput = 0)
	{
		MsgBox To use FavMenu with Windows Explorer you must enable Address Bar.`nEnable it in View->Toolbars.
		return 
	}

	ControlSetText, ,%path%, ahk_id %Favmenu_dlgInput%
	ControlSend, ,{ENTER},ahk_id %Favmenu_dlgInput%
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_Console(path, bTab = false)
{
	global Favmenu_Options_IAppend

	StringLeft, drive, path, 2
	SendInput, {HOME}echo {END}>c:\favmenu_contmp&%drive%&cd %path%&%Favmenu_Options_IAppend%{ENTER}
	Sleep 100
	FileReadLine prev, c:\favmenu_contmp, 1

	if (prev != "ECHO is on.") && (prev != "ECHO 处于打开状态。")
	{
		SendInput %prev%
	FileDelete c:\favmenu_contmp
	}
}

FavMenu_DialogSetPath_Emacs(path)
{
	SendInput ^g
	;; find-file
	SendInput ^x^f
	;; beginning-of-line, kill-line
	Sleep 100
	SendInput ^a^k
	Sleep 100
	
	SendInput %path%{ENTER}

	Sleep 100
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_OS(path)
{
	global 
	local d_text, d_f
	
	WinWaitActive ahk_id %FavMenu_dlgHWND%

	ControlGetFocus d_f, ahk_id %FavMenu_dlgHWND%
	ControlFocus, , ahk_id %FavMenu_dlgInput%

	ControlGetText d_text, ,ahk_id %FavMenu_dlgInput%
	ControlSetText, , %path%, ahk_id %FavMenu_dlgInput%
	ControlSend, ,{ENTER}, ahk_id %FavMenu_dlgInput%
	
	Sleep 20
	ControlSetText, ,%d_text%, ahk_id %FavMenu_dlgInput%
	if (FavMenu_dlgType = "Office03")
		ControlFocus %d_f%, ahk_id %FavMenu_dlgHWND%
}

;--------------------------------------------------------------------------

FavMenu_DialogSetPath_BFF( path )
{
	global

	BFFM_SETSELECTION := 0x400 + 102

	VarSetCapacity(wPath, StrLen( path ) * 2, 0)
	Favmenu_GetUnicodeString(wPath, path)

	bufID := RemoteBuf_Open(FavMenu_dlgHWND, 256)
	RemoteBuf_Write(bufId, Path , 256)
	adr := RemoteBuf_GetAdr(bufID)

	;SendMessage BFFM_SETSELECTION, 1, adr, ,ahk_class %FavMenu_dlgHWND%
	res := DllCall("SendMessageA"
         , "UInt", FavMenu_dlgHWND
         , "UInt", BFFM_SETSELECTION
         , "UInt", 1
         , "Uint", adr)

	RemoteBuf_Close( bufId )
}


;------------------------------------------------------------------------------------------------

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
