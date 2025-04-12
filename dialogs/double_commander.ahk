;; Double Commander >= 0.9.6

;; As built with Lazarus, Double Commander doesn't use normal windows controls.
;; Thus it's hard to get enough information from the UI components
;; (for example, the window text of the pane header is empty.)

Favmenu_DialogIsType_DoubleCommander(hwnd, klass, title)
{
	;; DC changed its window class to TTOTAL_CMD (the same as Total Commander) since 0.9.6

	;; For DC < 0.9.6, change klass to 'DClass'
	If (klass = "TTOTAL_CMD") and InStr(title, "Double Commander ")
	{
		;FavMenu_dlgType := "DoubleCommander"
		return 1
	}
}

Favmenu_DialogGetPath_DoubleCommander()
{
	global Favmenu_dlgHwnd

	curpath := Favmenu_DialogGetPath_DC_bg(Favmenu_dlgHwnd)
	if (curpath=) {
		curpath := Favmenu_DialogGetPath_DC_fg(Favmenu_dlgHwnd)
	}

	return curpath
}


FavMenu_DialogSetPath_DoubleCommander(path, bTab = false)
{
	global Favmenu_dlgHwnd

	WinActivate, ahk_id %Favmenu_dlgHwnd%

	;; FIXME: this reply on default keybindings. it won't work if user changed it
	if (bTab)
		Send,^t

	;; FIXME: this reply on default keybindings. it won't work if user changed it
	;; and it won't work if user choose to hide the 'command line'
	Send,+{F2}   ;;focus command line

	Send,{Home}+{End}{Delete}
	SendRaw, cd "%path%"
	Send, {ENTER}
}

Favmenu_DialogGetPath_DC_fg(hwndDC)
{
	Sleep,200   ;;wait FavMenu disappearing
	WinActivate, ahk_id %hwndDC%

	;; save old text of the Command Line control
	ControlGetText, oldcmd, Edit1, ahk_id %hwndDC%

	;; cm_AddPathToCmdLine    FIXME: this relies on default keybindings
	Send,^p     ;;Alt+C to activate menu item Commands
	Sleep,100

	ControlGetText, curpath, Edit1, ahk_id %hwndDC%

	if (oldcmd) {
		ControlSetText, Edit1, oldcmd, ahk_id %hwndDC%
	}

	return curpath
}

FavMenu_DialogGetAllPaths_DC()
{
	local arr := Object()
	local hwnd_active := WinActive()

	WinGet,id,List,ahk_class TTOTAL_CMD ahk_exe doublecmd.exe

	Loop,%id%
	{
		this_id := id%A_Index%
		if this_id == hwnd_active
			continue

		curpath := Favmenu_DialogGetPath_DC_bg(this_id)
		if (curpath)
		{
			arr.Insert(curpath)
		}
	}
	return arr
}

Favmenu_DialogGetPath_DC_bg(hwndDC)
{
	;; FIXME: by default, Double Commander won't show current path in its title
	;; you need to enable it in Options > Miscellaneous > Show current directory in the main window title bar
	path := Favmenu_DialogGetPath_fromTitle(hwndDC)
	;; if (path=)
	;; {
		;; TODO: any other way?
	;;}
	return path
}

