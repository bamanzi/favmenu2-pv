FavMenu_DialogGetPath_Xplorer2()
{
	global FavMenu_dlgHwnd
	rebar := Favmenu_FindWindowExId(Favmenu_dlgHwnd,  "ReBarWindow32", 0) 
	toolwin := Favmenu_FindWindowExID(rebar, "ToolbarWindow32", 60160) 
	combo := Favmenu_FindWindowExID(toolwin, "ComboBox", 0)
		
	if (combo)
	{
		ControlGetText, result, ComboBox1, ahk_id %FavMenu_dlgHwnd%
		return result
	}
	
}

FavMenu_DialogSetPath_Xplorer2(path, bTab = false)
{
	WinActivate, ahk_id %FavMenu_dlgHwnd%
	
	if (bTab)
	{
		SendInput,^{Ins}
	}
	
	Sleep 100
	
	SendInput, {F10}{HOME}+{END} ;;{DELETE}

	SendInput,%path%{ENTER}
	
	Sleep 100
	
}