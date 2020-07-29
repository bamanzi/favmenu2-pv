;; NOTE:
;;   * clipboard content changed

FavMenu_DialogGetPath_Cygwin()
{
	global Favmenu_dlgHwnd
	Winactivate,ahk_id %Favmenu_dlgHwnd%

	clipboard=
	Send,(cygpath -w -a . || cmd /c "cd") | clip{Enter}
	Sleep,500
	Stringtrimright,retvalue,clipboard,1
	return retvalue
}

;; Supported terminal: cmd.exe & mintty
;; TODO: PuTTYCyg support (?)
FavMenu_DialogSetPath_Cygwin(path)
{
	OutputDebug,FavMenu_DialogSetPath_Cygwin called
	;;SendInput, cd ``cygpath -u '%path%'``{ENTER}
	SendInput, pushd '%path%'{ENTER}  ;;this works for mintty for cygwin & msys
	Sleep 100
}
