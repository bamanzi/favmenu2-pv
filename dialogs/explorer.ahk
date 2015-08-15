Favmenu_DialogGetPath_Explorer()
{
	global Favmenu_dlgHwnd, Favmenu_dlgInput, FavMenu_msctls_progress32
	tv := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "BaseBar", 0) 
	tv := Favmenu_FindWindowExID(tv, "ReBarWindow32", 0) 
	tv := Favmenu_FindWindowExID(tv, "SysTreeView32", 100)

	TV_Initialise( FavMenu_dlgHWND, tv )
	returnedPath := TV_GetPath()
	if returnedPath <> 
		return returnedPath 
   
	;Nothing was returned. Perhaps Vista    
	FavMenu_GetExplorerInput()

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


FavMenu_GetExplorerInput()
{
	global
	Favmenu_dlgInput := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "WorkerW", 0) 
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
