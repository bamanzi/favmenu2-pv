Favmenu_DialogGetPath_TC()
{
	curDir := FavMenu_GetCurrentTCDir()
	StringGetPos idx, curDir, \, R

	if (idx != -1) && StrLen(curDir) > 3
			StringMid name, curDir, idx+2, 256
	else	StringMid name, curDir, 1, 2

	return curDir
}

FavMenu_DialogSetPath_TC(path, bTab = false)
{
	global 

	if (bTab)
		FavMenu_SendTCCommand(cm_OpenNewTab)
	
	WinActivate ahk_class TTOTAL_CMD

	FavMenu_SendTCCommand(cm_editpath)
	SendRaw, %path%
	Send, {ENTER}
}