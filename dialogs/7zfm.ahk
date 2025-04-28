;; 7zFM
;;
;; tested with 7-zip 19.00, 22.01, 23.01, 24.09

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
	WinGetTitle, title, ahk_id %hwnd%

	;; in case title pointing to an archive file, or path inside archive
	return Favmenu_get_parent_folder_until_dir(title)
}

FavMenu_DialogSetPath_7zFM(path1, bTab = false)
{
	global FavMenu_dlgHwnd

	WinActivate, ahk_id %FavMenu_dlgHwnd%

	;; FIXME: currently only left-panel supported
	Send,!{F1}
	Sleep,200
	;; cancel dropdown, so we can input path
	Send,{Esc}
	Sleep,100

	ControlSetText, Edit1, %path1%, ahk_id %FavMenu_dlgHwnd%
	Send,{Enter}
}
