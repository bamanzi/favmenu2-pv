;---------------------------------------------------------------------------

FavMenu_SendTCCommand(cmd, wait=1)
{
	if (wait)
		SendMessage 1075, cmd, 0, , ahk_class TTOTAL_CMD
	else
		PostMessage 1075, cmd, 0, , ahk_class TTOTAL_CMD
}
