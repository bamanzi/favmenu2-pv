;; WinSCP (ahk_class TScpCommanderForm)

;; tested in WinSCP 5.7
;; NOTE: Things would be easier if option 'Path in window title' set to 'Show full path'
;;	   (Options->Preferences->Window->Path in window title)

Favmenu_DialogIsType_WinSCP(hwnd, klass, title)
{
	If (class = "TScpCommanderForm")
	{
		;FavMenu_dlgType	 := "Console"
		return 1
	}
}

Favmenu_DialogGetPath_WinSCP()
{
	local title
	WinGetTitle,title,ahk_id %Favmenu_dlgHwnd%  

	;; if current pane is the remote filesystem, activate the other pane
	;; (only works when option 'Path in window title' set to 'Show full path')  
	if ("/" == SubStr(title, 1, 1)) 
	{
		WinActivate,ahk_id %Favmenu_dlgHwnd%
		Send,{Tab}
		Sleep,300
		WinGetTitle,title,ahk_id %Favmenu_dlgHwnd%
	}

	;; current pane is the local filesystem
	;; (only works when option 'Path in window title' set to 'Show full path')  
	if (":" == SubStr(title, 2, 1)) 
	{
		return Favmenu_DialogGetPath_FromTitle()
	}
	else
	{
		;; full path not shown in title, thus use Open Directory dialog to get current directory
		local title
		WinActivate,ahk_id %Favmenu_dlgHwnd%
		Send,^o
		Sleep 500

		ControlGetText, curDir, TIEComboBox1, ahk_class TOpenDirectoryDialog
		return curDir
	}	
} 

Favmenu_DialogSetPath_WinSCP(targetpath)
{
	local title
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

	;ControlSetText, TIEComboBox1, %path%, ahk_class TOpenDirectoryDialog
	;ControlFocus,TIEComboBox1, ahk_class TOpenDirectoryDialog
	;Send {Enter}

	;; focus directory combobox
	Send,!o
	;; delete old text
	Send,{Home}
	Send,+{End}
	Send,{Delete}

	SendInput,%targetpath%
	Send,{Enter}
}
