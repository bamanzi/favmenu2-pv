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
	;; (if user choose to hide the 'command line', this command would make it visible temporarily)
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
	if curpath not contains :\
	{
		OutputDebug, [Double Commander] ControlGetText('Edit1') returns empty, it seems Ctrl+P not working
		OutputDebug, ADVICE: [Double Commander] please check whether Ctrl+P bound to cm_AddPathToCmdLine (in Options > Hot Keys)
	}

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
	;; NOTE: by default, Double Commander won't show current path in its title
	path := Favmenu_DialogGetPath_fromTitle(hwndDC)
	if (!path)
	{
		OutputDebug, [Double Commander] Favmenu_DialogGetPath_fromTitle() returns empty.
		OutputDebug, ADVICE: [Double Commander] FavMenu2 recommend you turn on option 'Show current directory in the main window title bar' (in Options > Miscellaneous)
	}
	return path
}

