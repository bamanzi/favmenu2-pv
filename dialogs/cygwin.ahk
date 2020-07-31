;; No Favmenu_DialogIsType_Cygwin() here
;; As Cygwin doesn't have visual indicator on title or windows class
;; (it use cmd/mintty/rxvt as window, but some other things would also runs in cmd/mintty/rxvt)

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
