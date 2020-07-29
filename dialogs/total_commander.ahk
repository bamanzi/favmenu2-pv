;; Total Commander
;; ahk_class TTOTAL_CMD

Favmenu_DialogIsType_TC(hwnd, klass, title)
{
	if (klass = "TTOTAL_CMD")
	{
		;FavMenu_dlgType := "TC"
		return 1
	}
}

Favmenu_DialogGetPath_TC()
{
	curDir := FavMenu_GetCurrentTCDir(FavMenu_dlgHwnd)
	StringGetPos idx, curDir, \, R

	if (idx != -1) && StrLen(curDir) > 3
		StringMid name, curDir, idx+2, 256
	else
		StringMid name, curDir, 1, 2

	return curDir
}

FavMenu_DialogSetPath_TC(path, bTab = false)
{
	global 

	if (bTab)
		FavMenu_SendTCCommand(cm_OpenNewTab)
	
	;WinActivate ahk_class TTOTAL_CMD
	WinActivate, ahk_id %FavMenu_dlgHwnd%

	FavMenu_SendTCCommand(cm_editpath)
	SendRaw, %path%
	Send, {ENTER}
}

FavMenu_DialogGetAllPaths_TC()
{
	local arr := Object()
	local hwnd_active := WinActive()

	WinGet,id,List,ahk_class TTOTAL_CMD

	Loop,%id%
	{
		this_id := id%A_Index%
		if this_id == hwnd_active
			continue

		WinGetTitle, this_title, ahk_id %this_id%

		FavMenu_GetTCPanels(this_id, leftDir, rightDir)
		if leftDir
		{
            OutputDebug,enum_all_paths: tc left window=%this_id%`, title=%this_title%`, path=%leftDir%`n
            arr.Insert(leftDir)
		}
		if rightDir
		{
            OutputDebug,enum_all_paths: tc right window=%this_id%`, title=%this_title%`, path=%rightDir%`n
            arr.Insert(rightDir)
		}
	}

	return arr
}

;;--------------------------------------------------------------------------
;; internal functions
;;--------------------------------------------------------------------------

; set left and right panel and return source
;
FavMenu_GetTCPanels(hwnd_tc, ByRef pLeft, ByRef pRight)
{
	WinGetTitle, tcTitle, ahk_id %hwnd_tc%
	if tcTitle not contains 6.5 AND tcTitle not contains 7.0
	{
		ControlGetText pLeft,  TPathPanel1, ahk_id %hwnd_tc%
		ControlGetText pRight, TPathPanel2, ahk_id %hwnd_tc%
	}
	else
	{
		ControlGetText pLeft,  TMyPanel5, ahk_id %hwnd_tc%
		ControlGetText pRight, TMyPanel9, ahk_id %hwnd_tc%
	}

	StringReplace pLeft, pLeft, *.*
	StringReplace pRight, pRight, *.*
}

FavMenu_GetCurrentTCDir(hwnd_tc)
{
	WinGetActiveTitle,tcTitle
	Loop,10 {
		ControlGetText path, TMyPanel%A_Index%, ahk_id %hwnd_tc%
		StringRight, tail, path, 1
		IfEqual, tail, >
		{
			FileAppend, found file path on TMyPanel%A_Index%: %path%`n,*
			src = %path%
			break
		} 
	  }

	StringReplace src, src, >
	return src
}

