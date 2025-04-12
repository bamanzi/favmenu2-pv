;---------------------------------------------------------------------------

FavMenu_SendTCCommand(cmd, FavMenu_dlgHwnd, wait=1)
{
	if (wait)
		SendMessage 1075, cmd, 0, , ahk_id %FavMenu_dlgHwnd%
	else
		PostMessage 1075, cmd, 0, , ahk_id %FavMenu_dlgHwnd%
}
