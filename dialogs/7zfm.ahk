Favmenu_DialogIsType_7zFM(hwnd, klass, title)
{
	;; window class name changed to "7-Zip::FM" since 23.01
	If (klass = "FM") or (klass = "7-Zip::FM")
	{
		;FavMenu_dlgType := "7zFM"
		return 1
	}
}

FavMenu_DialogGetPath_7zFM()
{
	global FavMenu_dlgHwnd
	curpath := FavMenu_DialogGetPath_7zFM_bg(FavMenu_dlgHwnd)
	if (curpath)
	{
		return curpath
	}

}

FavMenu_DialogGetPath_7zFM_bg(hwnd)
{
	return Favmenu_DialogGetPath_fromTitle(hwnd)
}

FavMenu_DialogSetPath_7zFM(path1, bTab = false)
{
	global FavMenu_dlgHwnd

	WinActivate, ahk_id %FavMenu_dlgHwnd%

	Send,!{F1}
	Sleep,200
	;; cancel dropdown, so we can input path
	Send,{Esc}
	Sleep,100

	ControlSetText, Edit1, %path1%, ahk_id %FavMenu_dlgHwnd%
	Send,{Enter}
}