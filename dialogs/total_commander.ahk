;; Total Commander >= 9.0
;; ahk_class TTOTAL_CMD

;; NOTE:
;; - 32bit & 64bit have different control IDs (for the path panel & cmd line control)
;; - only versions >= 9.0 supported, as a vertical toolbar was added in version 9.0,
;;   which changed the control IDs

Favmenu_DialogIsType_TC(hwnd, klass, title)
{
	if (klass = "TTOTAL_CMD") and InStr(title, "Total Commander ")
	{
		;FavMenu_dlgType := "TC"
		return 1
	}
}

Favmenu_DialogGetPath_TC()
{
	global FavMenu_dlgHwnd
	WinGet, exename, ProcessName, ahk_id %FavMenu_dlgHwnd%

	if exename contains totalcmd64.exe
		curDir := FavMenu_GetCurrentTCDir64(FavMenu_dlgHwnd)
	else
		if exename contains totalcmd.exe
			curDir := FavMenu_GetCurrentTCDir32(FavMenu_dlgHwnd)

	return curDir
}

FavMenu_DialogSetPath_TC(path, bTab = false)
{
	global

	;WinActivate ahk_class TTOTAL_CMD
	WinActivate, ahk_id %FavMenu_dlgHwnd%

	if (bTab)
		FavMenu_SendTCCommand(cm_OpenNewTab, FavMenu_dlgHwnd)

	FavMenu_SendTCCommand(cm_editpath, FavMenu_dlgHwnd)
	sleep,200

	SendInput, %path%
	Send, {ENTER}
}

FavMenu_DialogGetAllPaths_TC()
{
	local hwnd_active := WinActive()

	list1 := FavMenu_DialogGetAllPaths_TC_bg(hwnd_active, true)
	list2 := FavMenu_DialogGetAllPaths_TC_bg(hwnd_active, false)

	for index, value in list2
		list1.Push(value)
	return list1
}

FavMenu_DialogGetAllPaths_TC_bg(hwnd_active, is_tc64)
{
	local arr := Array()

    exename = totalcmd.exe
	if is_tc64
		exename = totalcmd64.exe

	WinGet, hwnds, List, ahk_class TTOTAL_CMD ahk_exe %exename%

	Loop,%hwnds%
	{
		this_id := hwnds%A_Index%
		if (this_id == hwnd_active)
			continue

		WinGetTitle, this_title, ahk_id %this_id%

		if is_tc64
			FavMenu_GetTCPanels64(this_id, leftDir, rightDir)
		else
			FavMenu_GetTCPanels32(this_id, leftDir, rightDir)

		if leftDir
		{
            OutputDebug, enum_all_paths: tc exe=[%exename%] window=[%this_id%] title=[%this_title%] left  path=%leftDir%
            arr.Push(leftDir)
		}
		if rightDir
		{
            OutputDebug, enum_all_paths: tc exe=[%exename%] window=[%this_id%]  title=[%this_title%] right path=%rightDir%
            arr.Push(rightDir)
		}
	}

	return arr
}

;;--------------------------------------------------------------------------
;; internal functions
;;--------------------------------------------------------------------------
FavMenu_GetTCPanels64(hwnd_tc, ByRef pLeft, ByRef pRight)
{
	WinGetTitle, tcTitle, ahk_id %hwnd_tc%

	ControlGetText pLeft,  Window10, ahk_id %hwnd_tc%
	ControlGetText pRight, Window15, ahk_id %hwnd_tc%

	;; remove trailing wildcards (e.g. *.* or abc*.docx) and in-archive parts
	;;pLeft := StrReplace(pLeft, "*.*")
	;;pRight := StrReplace(pRight, "*.*")
	pLeft := Favmenu_get_parent_folder_until_dir(pLeft)
	pRight := Favmenu_get_parent_folder_until_dir(pRight)
}

FavMenu_GetTCPanels32(hwnd_tc, ByRef pLeft, ByRef pRight)
{
	WinGetTitle, tcTitle, ahk_id %hwnd_tc%

	ControlGetText pLeft,  TPathPanel1, ahk_id %hwnd_tc%
	ControlGetText pRight, TPathPanel2, ahk_id %hwnd_tc%

	;; remove trailing filter
	;;pLeft := StrReplace(pLeft, "*.*")
	;;pRight := StrReplace(pRight, "*.*")
	pLeft := Favmenu_get_parent_folder_until_dir(pLeft)
	pRight := Favmenu_get_parent_folder_until_dir(pRight)
}

FavMenu_GetCurrentTCDir64(hwnd_tc)
{
	WinGetTitle,tcTitle,ahk_id %hwnd_tc%

    ControlGetText curpath, Window6, ahk_id %hwnd_tc%

	curpath := StrReplace(curpath, ">")
	return curpath
}

FavMenu_GetCurrentTCDir32(hwnd_tc)
{
	WinGetTitle,tcTitle,ahk_id %hwnd_tc%

    ControlGetText curpath, TMyPanel3, ahk_id %hwnd_tc%

	;; remove trailing '>'
	curpath := StrReplace(curpath, ">")
	return curpath
}

