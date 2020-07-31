;; As built with Lazarus, Double Commander doesn't use normal windows controls.
;; Thus it's hard to get enough information from the UI components 
;; (for example, the window text of the pane header is empty.)

Favmenu_DialogGetPath_DoubleCommander()
{
	global Favmenu_dlgHwnd

	Sleep,200   ;;wait FavMenu disappearing
	WinActivate, ahk_id %Favmenu_dlgHwnd%

	Send,!c     ;;Alt+C to activate menu item Commands
	Sleep,200
	Send,s	    ;; menu item 'Search'
	Sleep,300
	
	WinWait,Find files
	ControlGetText,vPath,Edit6,File files
	OutputDebug,DoubleCommander ControlGetText from 'Edit6' returns: '%vPath%'
	If vPath and SubStr(vPath,2,1) = ":"
		return vPath
	
	;; try another way
	
	;; FIXME: clipboard content changed
	Send,!d	    ;; Activate 'Start in directory' editbox
	Sleep,300
	Send,^c     ;; Copy
	Sleep,300
	OutputDebug,GetPath_DoubleCommander: clipboard=%clipboard%
	Send,{Esc}

	SplitPath,clipboard,,path

	OutputDebug,GetPath_DoubleCommander: path=%path%
	return path

}

FavMenu_DialogSetPath_DoubleCommander(path, bTab = false)
{
	global Favmenu_dlgHwnd

	WinActivate, ahk_id %Favmenu_dlgHwnd%

	;; FIXME: this reply on default keybindings. it won't work if user changed it
	if (bTab)
		Send,^t

	;; FIXME: this reply on default keybindings. it won't work if user changed it
	;; and it won't work if user choose to hide the 'command line'
	Send,+{F2}   ;;focus command line

	Send,{Home}+{End}{Delete}
	SendRaw, cd "%path%"
	Send, {ENTER}
}

