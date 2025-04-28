;; Xplorer2
;; ahk_class ATL:ExplorerFrame

Favmenu_DialogIsType_Xplorer2(hwnd, klass, title)
{
	If (klass = "ATL:ExplorerFrame")
	{
		;FavMenu_dlgType := "Xplorer2"
		return 1
	}
}

FavMenu_DialogGetPath_Xplorer2()
{
	global FavMenu_dlgHwnd
	curpath := FavMenu_DialogGetPath_Xplorer2_bg(FavMenu_dlgHwnd)
	if (curpath) {
		return Favmenu_get_parent_folder_until_dir(curpath)
	}
}

FavMenu_DialogSetPath_Xplorer2(path1, bTab = false)
{
	global FavMenu_dlgHwnd
	WinActivate, ahk_id %FavMenu_dlgHwnd%
	
	if (bTab)
	{
		SendInput,^{Ins}
		Sleep 200
	}

	;; focus the address bar (and it should force address bar visible)
	SendInput, {F10} ;;{HOME}+{END} ;;{DELETE}
	;;;SendInput,%path1%{ENTER}

	;; but sometimes F10 can't successfully set focus to address bar.
    ;; thus ControlSetText is reliable than SendInput
	Sleep 200
	ControlSetText, Edit1, %path1%, ahk_id %FavMenu_dlgHwnd%
	ControlFocus, Edit1, ahk_id %FavMenu_dlgHwnd%
	ControlSend, Edit1, {Enter}, ahk_id %FavMenu_dlgHwnd%
}

FavMenu_DialogGetAllPaths_Xplorer2()
{
	local arr := Object()
	local hwnd_active := WinActive()

	WinGet,id,List,ahk_class ATL:ExplorerFrame

	Loop,%id%
	{
		this_id := id%A_Index%
		if (this_id == hwnd_active)
			continue

		WinGetTitle, this_title, ahk_id %this_id%

		;; TODO: find a way to get the titles of both panel (which shows the current path) from xplorer2
		curDir := FavMenu_DialogGetPath_Xplorer2_bg(this_id)
		OutputDebug,enum_all_paths: xplorer window=%this_id%`, title=%this_title%`, path=%curDir%
		if (curDir)
		{
			arr.Insert(curDir)
		}
	}

	return arr
}

;;--------------------------------------------------------------------------
;; internal functions
;;--------------------------------------------------------------------------

FavMenu_DialogGetPath_Xplorer2_bg(hwnd_x2)
{
	rebar := Favmenu_FindWindowExId(hwnd_x2,  "ReBarWindow32", 0)
	toolwin := Favmenu_FindWindowExID(rebar, "ToolbarWindow32", 60160)
	combo := Favmenu_FindWindowExID(toolwin, "ComboBox", 0)

	if (combo)
	{
		ControlGet, comboVisible, Visible,, ComboBox1, ahk_id %hwnd_x2%
		if (!comboVisible)
		{
			OutputDebug, WARN [xplorer2] address bar not visible, in which case xplorer2 won't update the address
			OutputDebug, ADVICE [xplorer2] it is adviced to make the address bar visible
			return
		}
		
		ControlGetText, result, ComboBox1, ahk_id %hwnd_x2%

		;; in case in archive (e.g. zip)
		return Favmenu_get_parent_folder_until_dir(result)
	}
}
