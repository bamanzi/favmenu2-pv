;; - BFF (BrowseForFolder)
;; - OpenSave (Open/Save dialog) 
;;       - special handling: Office 2003 Open/Save dialog

;; FIXME: GetPath_OpenSave not work on windows 10 open/save dialog

FavMenu_DialogIsType_BFF(dlg, klass, title)
;FavMenu_IsBrowseForFolder( dlg )
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
	;FavMenu_dlgType	 := "BFFDialog"

	return 1
}

Favmenu_DialogGetPath_BFF()
{
	global

	TV_Initialise( FavMenu_dlgHWND, FavMenu_dlgInput )
	return TV_GetPath()
}

FavMenu_DialogSetPath_BFF( path )
{
	global FavMenu_dlgHWND

	edit1 := FavMenu_FindWindowExID(FavMenu_dlgHWND, "Edit1", 0)
	if edit1
		ControlSetText, Edit1, %path%, ahk_id %FavMenu_dlgHWND%
	else {
		;; FIXME: this seems not work any longer
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
}

;------------------------------------------------------------------------------------------------

FavMenu_DialogGetPath_OpenSave()
{
	return FavMenu_DialogGetPath_OS()
}

FavMenu_DialogSetPath_OpenSave(path, bTab=false)
{
	FavMenu_DialogSetPath_OS(path)
}

;------------------------------------------------------------------------------------------------

FavMenu_IsOpenSave(dlg)
{
	global FavMenu_dlgInput, FavMenu_dlgType, FavMenu_msctls_progress32, bread
   
	FavMenu_dlgType =

	toolbar := FavMenu_FindWindowExID(dlg, "ToolbarWindow32", 0x440)   ;windows XP
	if (toolbar = "0")
		toolbar := FavMenu_FindWindowExID(dlg, "ToolbarWindow32", 0x001)  ;windows 2k

	; Windows 7 OpenSave
	rebar := FavMenu_FindWindowExID(dlg, "WorkerW", 0)
	rebar := FavMenu_FindWindowExID(rebar, "ReBarWindow32", 0)
	rebar := FavMenu_FindWindowExID(rebar, "Address Band Root", 0)
	rebar := FavMenu_FindWindowExID(rebar, "msctls_progress32", 0)
	FavMenu_msctls_progress32 := rebar
	rebar := FavMenu_FindWindowExID(rebar, "Breadcrumb Parent", 0)
	bread := rebar
	rebar := FavMenu_FindWindowExID(rebar, "ToolbarWindow32", 0)
	 
	combo  := FavMenu_FindWindowExID(dlg, "ComboBoxEx32", 0x47C) ; comboboxex field
	button := FavMenu_FindWindowExID(dlg, "Button", 0x001)		; second button
	 
	edit := FavMenu_FindWindowExID(dlg, "Edit", 0x480)			; edit field
	 
	if ((rebar || (toolbar && (combo || edit))) && button) 
	{
		FavMenu_dlgInput   := combo + edit
		if rebar
			FavMenu_dlgInput   := rebar
		FavMenu_dlgType      := "OpenSave"
		return 1
	}

	return FavMenu_IsOffice03(dlg)
}


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

FavMenu_DialogSetPath_OS(path)
{
	global 
	local d_text, d_f
	
	WinWaitActive ahk_id %FavMenu_dlgHWND%

	ControlGetFocus d_f, ahk_id %FavMenu_dlgHWND%
	ControlFocus, , ahk_id %FavMenu_dlgInput%

	Sleep 20
	if FavMenu_msctls_progress32
	{
		ControlSend, ,{Space}, ahk_id %FavMenu_dlgInput%
		Sleep 20
		rebar := FavMenu_FindWindowExID(FavMenu_msctls_progress32, "ComboBoxEx32", 0)
		rebar := FavMenu_FindWindowExID(rebar, "ComboBox", 0)
		rebar := FavMenu_FindWindowExID(rebar, "Edit", 0)
		if rebar
		{
			Sleep 20
			ControlSetText, , %path%, ahk_id %rebar%
			ControlSend, ,{ENTER}, ahk_id %rebar%
		}
	}
	else
	{
		ControlGetText d_text, ,ahk_id %FavMenu_dlgInput%
		ControlSetText, , %path%, ahk_id %FavMenu_dlgInput%
		ControlSend, ,{ENTER}, ahk_id %FavMenu_dlgInput%
	}
	Sleep 20
	if (FavMenu_dlgType = "Office03")
		ControlFocus %d_f%, ahk_id %FavMenu_dlgHWND%
}

