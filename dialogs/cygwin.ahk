;; TODO: implement GetPath
;;    (maybe: `cygpath -w -a . | clip`   but 'cygpath' is required


;; Supported terminal: cmd.exe & mintty
;; TODO: PuTTYCyg support (?)
FavMenu_DialogSetPath_Cygwin(path)
{
	OutputDebug,FavMenu_DialogSetPath_Cygwin called
	;;SendInput, cd ``cygpath -u '%path%'``{ENTER}
	SendInput, pushd '%path%'{ENTER}  ;;this works for mintty for cygwin & msys
	Sleep 100
}