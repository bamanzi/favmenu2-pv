;; TODO: currently we use a temp file to store the current path
;;     maybe `cd | clip` is a better way?
Favmenu_DialogGetPath_Console()
{
	WinGetActiveTitle,Title
	if InStr(Title, "} - Far ") > 1
	{
		;;FAR manager
		;;e.g.   {D:\wintools\FAR2} - Far 2.0.1777 x86 Administrator
		curDir := SubStr(Title, 2, InStr(Title, "}") - 2)
		OutputDebug,DialogGetPath_Console returns %curDir%
		return curDir
	}
	SendInput {HOME}echo {END}>c:\favmenu_contmp&echo `%cd`%>>c:\favmenu_contmp{ENTER}
	Sleep 100

	FileReadLine prev, c:\favmenu_contmp, 1
	FileReadLine curDir, c:\favmenu_contmp, 2
	FileDelete c:\favmenu_contmp
	
	if (prev != "ECHO is on.") && (prev != "ECHO 处于打开状态。")
		SendInput %prev%
	
	return curDir
}

;; implementation: issue command 'cd /d "%path"' into the console
;; thus if some other application running in the console, it won't work
FavMenu_DialogSetPath_Console(path, bTab = false)
{
	global Favmenu_Options_IAppend

	WinGetActiveTitle,Title
	WinGetClass,class
	If class = "Console_2_Main")
	{
	    ;; Console2 has problems when SendInput (it would change : to ;)
	    Clipboard = cd /d "%path%"
	    SendInput, +{Insert}{Enter}
	}
	else if InStr(Title, "- Far ")>1
	{
		;; FAR manager  ;;TODO: support tabs (PanelTabs plugin)
		SendInput ^y    ;;clear command line
		SetKeyDelay,30  ;;FAR's auto-completion would make the keystroke not accurate
		SendInput cd /d %path%{ENTER}
		
	}
	Else
	{
		;StringLeft, drive, path, 2
		;SendInput, {HOME}echo {END}>c:\favmenu_contmp&%drive%&cd %path%&%Favmenu_Options_IAppend%{ENTER}
		;Sleep 100
		;FileReadLine prev, c:\favmenu_contmp, 1

		;if (prev != "ECHO is on.") && (prev != "ECHO 处于打开状态。")
		;;	SendInput %prev%
		;FileDelete c:\favmenu_contmp
		
		SendInput cd /d %path%{ENTER}
	}
}