;; currently only tested on XYplorer Free 14.50 & 17.00
;; TODO: fix support for XYplorer Pro

Favmenu_DialogIsType_XYplorer(hwnd, klass, title)
{
	If (klass = "ThunderRT6FormDC") and ((title contains " - XYplorerFree ") or (title contains " - XYplorer "))
	{
		;FavMenu_dlgType := "XYplorer"
		return 1
	}
}

FavMenu_DialogGetPath_XYplorer()
{
	global FavMenu_dlgHwnd

	;; FIXME: this relies on the title bar template, by default it's '<path> - <app> <ver>'
	;; (menu Tools -> Configuration -> Colors and Styles -> Templates -> Titlebar)
	path := Favmenu_DialogGetPath_FromTitle()

	if FileExist(path)
	{
		OutputDebug, FavMenu_DialogGetPath_XYplorer returns: title=%path%
	} else 
	{
		;; if Favmenu_DialogGetPath_FromTitle failed, try another way   
		;; NOTE: if you changed XYplorer's title bar template, the app recognition method 
		;;       in FavMenu_DialogGetActive() should be updated correspondingly.
		WinActivate, ahk_id %FavMenu_dlgHwnd%
		Send,!d  ;;focus to address bar
		Send,{HOME}+{END}
		Send,^c
		path := clipboard

		OutputDebug, FavMenu_DialogGetPath_XYplorer returns: clipboard=%clipboard%
	}

	return path
}

FavMenu_DialogSetPath_XYplorer(path, bTab = false)
{
	global FavMenu_dlgHwnd
	OutputDebug,FavMenu_DialogSetPath_XYplorer called with FavMenu_dlgHwnd = %FavMenu_dlgHwnd%`n

	WinActivate, ahk_id %FavMenu_dlgHwnd%

	if (bTab)
	{
		SendInput,^t
	}

	Sleep 200

	;; bring up Go to dialog
	Send, ^g

	Sleep 200

	SendInput, %path%

	Send, {ENTER}

	Sleep 100
}
