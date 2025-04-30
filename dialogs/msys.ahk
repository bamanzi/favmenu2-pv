;; msys2 & git-for-windows

Favmenu_DialogIsType_Msys(hwnd, klass, title)
{
	If (InStr(title, "MINGW32:", true)>0) or (InStr(title, "MINGW64:", true)>0) or (InStr(title, "MSYS:", true)>0)
	{
		;FavMenu_dlgType := "Msys"
		return 1
	}
}

FavMenu_DialogGetPath_Msys()
{
	global Favmenu_dlgHwnd
	Winactivate,ahk_id %Favmenu_dlgHwnd%

	;; First we try to parse path from the title
	WinGetActiveTitle, title
	regex := "(MINGW32|MINGW64|MSYS):" . FavMenu_Options_MsysRootMount . "([a-zA-Z])/"
	path1 := RegExReplace(title, regex, "$2:/")  ;; extract drive part
	path2 := StrReplace(path1, "/", "\")
	if FileExist(path2)
		return path2

	;; then try with command `cygpath -a . | clip`
	;; NOTE:
	;;   * clipboard content changed
	;;   * 'cygpath' from package 'cygutils' required 
	;;     (http://sourceforge.net/projects/mingw/files/MSYS/Extension/cygutils/)
	clipboard=
	Send,(cygpath -w -a . || cmd /c "cd") | clip{Enter}
	Sleep,500
	Stringtrimright,retvalue,clipboard,1
	return retvalue
}

;; Currently cmd.exe and console2/consolez supported
;; TODO: support other front-ends (such as ConEmu, Mintty, ColorConsole...)

FavMenu_DialogSetPath_Msys(path1, bTab = false)
{
	;;other front-ends: cmd, rxvt, mintty, conemu
	WinGetClass,klass,A
	path1 := RegExReplace(path, "\\$", "")
	OutputDebug,FavMenu_DialogSetPath_Msys called with klass=%klass%, path=%path1%
	
	If klass = Console_2_Main
	{
		OutputDebug,put clipboard content: [pushd '%path1%']
		;;Console2 has problems when SendInput (it would change : to ;)
		Clipboard = pushd '%path1%'
		SendInput, +{Insert}{Enter}
	}
	else
	{
		 SendInput pushd '%path1%'{ENTER}
	}
}
