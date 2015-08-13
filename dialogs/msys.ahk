;; TODO: implement GetPath
;;    (maybe: `cygpath -w -a . | clip`   but 'cygpath' is required


;; Currently cmd.exe and console.exe supported
;; TODO: support other front-ends (such as ConEmu, Mintty, ColorConsole...)
;; TODO: testing against ConsoleZ

FavMenu_DialogSetPath_Msys(path, bTab = false)
{
	;;other front-ends: cmd, rxvt, mintty, conemu
	WinGetClass,klass,A
	path1 := RegExReplace(path, "\\$", "")
	OutputDebug,FavMenu_DialogSetPath_Msys called with klass=%klass%, path=%path1%
	
	If klass = Console_2_Main
	{
		OutputDebug,put clipboard content: "cd %path1%"
		;;Console2 has problems when SendInput (it would change : to ;)
		 Clipboard = cd "%path1%"
		SendInput, +{Insert}{Enter}
	}
	else
	{
		 SendInput cd "%path%"{ENTER}
	}
}