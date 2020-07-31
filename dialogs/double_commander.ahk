;; As built with Lazarus, Double Commander doesn't use normal windows controls.
;; Thus it's hard to get enough information from the UI components 
;; (for example, the window text of the pane header is empty.)

Favmenu_DialogIsType_DoubleCommander(hwnd, klass, title)
{
	If (klass = "DClass") and ("Double Commander "==substr(title, 1, StrLen("Double Commander ")))
	{
		;FavMenu_dlgType := "DoubleCommander"
		return 1
	}
}

;; FIXME: clipboard content changed
Favmenu_DialogGetPath_DoubleCommander()
{
	global Favmenu_dlgHwnd

	Sleep,200   ;;wait FavMenu disappearing
	WinActivate, ahk_id %Favmenu_dlgHwnd%

	Send,!c     ;;Alt+C to activate menu item Commands
	Sleep,200
	Send,s	    ;; menu item 'Search'
	Sleep,400
	Send,!d	    ;; Activate 'Start in directory' editbox
	Sleep,200
	Send,^c     ;; Copy
	OutputDebug,GetPath_DoubleCommander: clipboard=%clipboard%

	SplitPath,clipboard,,path

	OutputDebug,GetPath_DoubleCommander: path=%path%
	return path

}


FavMenu_DialogSetPath_DoubleCommander(path, bTab = false)
{
	global Favmenu_dlgHwnd

	WinActivate, ahk_id %Favmenu_dlgHwnd%

	if (bTab)
		Send,^t

	;; FIXME: this reply on default keybindings. it won't work if user changed it
	;; and it won't work if user choose to hide the 'command line'
	Send,+{F2}   ;;focus command line

	Send,{Home}+{End}{Delete}
	SendRaw, cd "%path%"
	Send, {ENTER}
}

