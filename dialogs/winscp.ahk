;; WinSCP (ahk_class TScpCommanderForm)

;; tested in WinSCP 5.15.4, 5.17, 5.21, 6.1,x, 6.3.x
;;
;; NOTE:
;;   - For GetPath, things would be easier if option 'Path in window title' set to 'Show full path'
;;	   (Options->Preferences->Window->Path in window title)
;;   - Only works in local panels of Commander mode (because only remote panels show up in Explorer mode)

Favmenu_DialogIsType_WinSCP(hwnd, klass, title)
{
	If (klass = "TScpCommanderForm")
	{
		;FavMenu_dlgType	 := "WinSCP"

		if ("/" <> SubStr(title, 1, 1)) and (":\" <> SubStr(title, 2, 2)) and ("\\" <> SubStr(title, 1, 2))
		{
			OutputDebug,winscp: can't determine is current panel local or remote by window title: %title%
			OutputDebug,ADVICE: [WinSCP] it is HIGHLY adviced to set option 'Path in window title' to 'Show full path' (in Options > Preferences > Window)
		}

		return 1
	}
}

Favmenu_DialogGetPath_WinSCP()
{
	global Favmenu_dlgHwnd
	WinGetTitle,title,ahk_id %Favmenu_dlgHwnd%

	;; if current pane is the remote filesystem, activate the other pane
	;; (only works when option 'Path in window title' set to 'Show full path')
	if ("/" <> SubStr(title, 1, 1))
	{
		WinActivate,ahk_id %Favmenu_dlgHwnd%
		Send,{Tab}
		Sleep,300
		WinGetTitle,title,ahk_id %Favmenu_dlgHwnd%
	}

	;; current pane is the local filesystem
	;; (only works when option 'Path in window title' set to 'Show full path')
	if (":" == SubStr(title, 2, 1)) or ("\\" == SubStr(title, 1, 2))
	{
		;; workaround for WinSCP 6.x which use EN DASH (–) as separator
		;; (old versions use normal dash '-' (HYPHEN-MINUS))
		;; NOTE: current script should be saved as UTF-8 with BOM!!
		sep := InStr(title, " – ")
		if (sep == 0)
		{
			sep := InStr(title, " - ")
		}

		if (sep)
		{
			curpath := SubStr(title, 1, sep)
			If (InStr(FileExist(curpath), "D")>0)
				return curpath
		}
	}
	else
	{
		;; full path not shown in title, thus use Open Directory dialog to get current directory
		WinActivate, ahk_id %Favmenu_dlgHwnd%
		Send,^o
		Sleep 500

		ControlGetText, curDir, Edit2, ahk_class TOpenDirectoryDialog
		Send, {Esc}, ahk_class TOpenDirectoryDialog

		;; in case we're in a remote panel
		if IsDir(curDir)
			return curDir
	}
}

Favmenu_DialogSetPath_WinSCP(targetpath)
{
	global Favmenu_dlgHwnd
	WinGetTitle,title,ahk_id %Favmenu_dlgHwnd%

	;; if current pane is the remote filesystem, activate the other pane
	;; (require option set: (Options->Preferences->Window->Path in window title)
	if ("/" == SubStr(title, 1, 1))
	{
		WinActivate,ahk_id %Favmenu_dlgHwnd%
		Send,{Tab}
		Sleep,300
	}

	;; open 'Open Directory' dialog
	WinActivate,ahk_id %Favmenu_dlgHwnd%
	Send,^o
	Sleep 500

	;ControlSetText, Edit2, %targetpath%, ahk_class TOpenDirectoryDialog
	;ControlFocus, Edit2, ahk_class TOpenDirectoryDialog
	;ControlSend, Edit2, {Enter}, ahk_class TOpenDirectoryDialog

	;; focus directory combobox
	Send,!o
	;; delete old text
	Send,{Home}
	Send,+{End}
	Send,{Delete}

	SendInput,%targetpath%
	Send,{Enter}
}
