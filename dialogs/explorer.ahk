;; Windows Explorer
;; ahk_class CabinetWClass

Favmenu_DialogGetPath_Explorer()
{
	global FavMenu_dlgHwnd
	return Favmenu_DialogGetPath_Explorer_bg(FavMenu_dlgHwnd)
}

FavMenu_DialogSetPath_Explorer(path, bTab = false)
{
	global
	
	If FavMenu_msctls_progress32
	{
		FavMenu_DialogSetPath_OS(path)
		Return
	}
	
	if (Favmenu_dlgInput = 0)
	{
		MsgBox To use FavMenu with Windows Explorer you must enable Address Bar.`nEnable it in View->Toolbars.
		return 
	}

	ControlSetText, ,%path%, ahk_id %Favmenu_dlgInput%
	ControlSend, ,{ENTER},ahk_id %Favmenu_dlgInput%
}

Favmenu_DialogGetAllPaths_Explorer()
{
	local arr := Object()

	WinGet,id,List,ahk_class CabinetWClass

	Loop,%id%
	{
		this_id := id%A_Index%
		curDir := FavMenu_DialogGetPath_Explorer_bg(this_id)

		WinGetTitle, this_title, ahk_id %this_id%
		OutputDebug enum_all_paths: explorer window=%this_id%`, path=%curDir%`, title=%this_title%`n,*		
		if curDir
			arr.Insert(curDir)
	}

	return arr
}

;;--------------------------------------------------------------------------
;; internal functions
;;--------------------------------------------------------------------------


Favmenu_DialogGetPath_Explorer_bg(hwnd_explorer)
{
	;;global Favmenu_dlgInput, FavMenu_msctls_progress32
	tv := Favmenu_FindWindowExId(hwnd_explorer,  "BaseBar", 0) 
	tv := Favmenu_FindWindowExID(tv, "ReBarWindow32", 0) 
	tv := Favmenu_FindWindowExID(tv, "SysTreeView32", 100)

	TV_Initialise(hwnd_explorer, tv)
	returnedPath := TV_GetPath()
	if returnedPath <> 
		return returnedPath 
   
	;Nothing was returned. Perhaps Vista    
	FavMenu_GetExplorerInput(hwnd_explorer, Favmenu_dlgInput, FavMenu_msctls_progress32)

	If FavMenu_msctls_progress32
	{
		OutputDebug,FavMenu_msctls_progress32=%FavMenu_msctls_progress32%`n
		rebar := FavMenu_FindWindowExID(FavMenu_msctls_progress32, "Breadcrumb Parent", 0)
		bread := rebar
		rebar := FavMenu_FindWindowExID(rebar, "ToolbarWindow32", 0)
		
		ControlGetText, EditCtrlPath, , ahk_id %rebar%
		OutputDebug,EditCtrlPath=%EditCtrlPath%`n
		pos1 := InStr(EditCtrlPath, ":")
		If pos1
		{
			EditCtrlPath := SubStr(EditCtrlPath, pos1+2)
			OutputDebug,EditCtrlPath=%EditCtrlPath%`n
		}
	}
	Else
	{
		;MsgBox, Editcontrol %Favmenu_dlgInput%
		ControlGetText, EditCtrlPath, , ahk_id %Favmenu_dlgInput%
		;Msgbox, %EditCtrlPath%
	}
	return  %EditCtrlPath%
}



FavMenu_GetExplorerInput(hwnd_explorer, byref Favmenu_dlgInput, byref FavMenu_msctls_progress32)
{
	;global
	Favmenu_dlgInput := Favmenu_FindWindowExId(hwnd_explorer,  "WorkerW", 0) 
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ReBarWindow32", 0) 
	;Remember last good value. If Vista, we need the value to retry
	Favmenu_dlgInputOriginal := Favmenu_dlgInput

	;Try Combobox. If Vista, that command fails
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBoxEx32", 0)
	
	if Favmenu_dlgInput = 0
	{
		;Perhaps Vista... ??? Use Favmenu_dlgInputOriginal
		Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInputOriginal, "Address Band Root", 0)   
		Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "msctls_progress32", 0)
		FavMenu_msctls_progress32 := Favmenu_dlgInput
		Return
	}
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBoxEx32", 0)
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "ComboBox", 0)
	Favmenu_dlgInput := Favmenu_FindWindowExID(Favmenu_dlgInput, "Edit", 0)
}
