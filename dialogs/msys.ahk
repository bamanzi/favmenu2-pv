;; NOTE:
;;   * clipboard content changed
;;   * 'cygpath' from package 'cygutils' required 
;;     (http://sourceforge.net/projects/mingw/files/MSYS/Extension/cygutils/)
FavMenu_DialogGetPath_Msys()
{
	global Favmenu_dlgHwnd
	Winactivate,ahk_id %Favmenu_dlgHwnd%

	clipboard=
	Send,(cygpath -w -a . || cmd /c "cd") | clip{Enter}
	Sleep,500
	Stringtrimright,retvalue,clipboard,1
	return retvalue
}

;; Currently cmd.exe and console2/consolez supported
;; TODO: support other front-ends (such as ConEmu, Mintty, ColorConsole...)

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
