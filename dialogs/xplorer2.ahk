;; Xplorer2
;; ahk_class ATL:ExplorerFrame

FavMenu_DialogGetPath_Xplorer2()
{
    global FavMenu_dlgHwnd
	return FavMenu_DialogGetPath_Xplorer2_bg(FavMenu_dlgHwnd)
}

FavMenu_DialogSetPath_Xplorer2(path, bTab = false)
{
	global FavMenu_dlgHwnd
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

FavMenu_DialogGetAllPaths_Xplorer2()
{
    local arr := Object()

    WinGet,id,List,ahk_class ATL:ExplorerFrame

    Loop,%id%
    {
		this_id := id%A_Index%
		WinGetTitle, this_title, ahk_id %this_id%

		curDir := FavMenu_DialogGetPath_Xplorer2_bg(this_id)
		OutputDebug,enum_all_paths: xplorer window=%this_id%`, title=%this_title%`, path=%curDir%    
		if curDir
			arr.Insert(curDir)
    }

    return arr
}

;;--------------------------------------------------------------------------
;; internal functions
;;--------------------------------------------------------------------------

FavMenu_DialogGetPath_Xplorer2_bg(FavMenu_dlgHwnd)
{
	rebar := Favmenu_FindWindowExId(FavMenu_dlgHwnd,  "ReBarWindow32", 0) 
	toolwin := Favmenu_FindWindowExID(rebar, "ToolbarWindow32", 60160) 
	combo := Favmenu_FindWindowExID(toolwin, "ComboBox", 0)
		
	if (combo)
	{
		ControlGetText, result, ComboBox1, ahk_id %FavMenu_dlgHwnd%
		return result
	}
	
}
