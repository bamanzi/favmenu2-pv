;; Tested in FreeCommander & FreeCommanderXE

Favmenu_DialogIsType_FreeCommander(hwnd, klass, title)
{
	If (klass = "TfcForm") Or (klass="FreeCommanderXE.SingleInst.1")
	{
		;FavMenu_dlgType := "FreeCommander"
		return 1
	}
}

Favmenu_DialogGetPath_FreeCommander()
{
	local title
	WinGetClass, class, ahk_id %Favmenu_dlgHwnd%
	;~ if class="TfcForm"
	;~ {
		;~ ;;FreeCommander
		;~ Send,!g
		;~ Sleep 100
		;~ ControlGetText, path, TfcPathEdit
		;~ Send {ESC}
		;~ return path
	;~ }else ;;if class="FreeCommanderXE.SingleInst.1"
	;~ { ;;FreeCommanderXP
		;~ Send,!g
		;~ Sleep 100
		;~ ControlGetText, path, TfcPathEdit
		;~ Send {ESC}
		;~ return path
	;~ }
	WinActivate,ahk_id %Favmenu_dlgHwnd%
	Send,!g
	Sleep 300
	;;ControlGetText, fcpath, ahk_class TfcPathEdit
	Send,^c
	Send {ESC}
	return %Clipboard%
} 

Favmenu_DialogSetPath_FreeCommander(path, bTab = false)
{
	WinActivate,ahk_id %Favmenu_dlgHwnd%
	if bTab
	{
		Send,^t
		Sleep,300
	}
	Send,!g
	Sleep 300
	;;ControlGetText, fcpath, ahk_class TfcPathEdit
	SendRaw,%path%
	Send {Enter}
}