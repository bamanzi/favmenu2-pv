;; Tested on GNU Emacs, XEmacs & MicroEmacs-jasspa

Favmenu_DialogGetPath_Emacs()
{
	;;TODO: ensure compatibility of XEmacs
  
	WinGetActiveTitle,Title

	;; cancel current thing if any
	SendInput ^g
	;; find-file
	SendInput ^x^f
	;; begging-of-line
	SendInput ^a

	;; set-mark
	if InStr(Title, " MicroEmacs")>1
	{
		;;tested on MicroEmacs-jasspa
		SendInput {Esc}{Space}
	}
	Else
	{
		SendInput ^+2  ;; C-@
	}
	;; move-end-of-line
	SendInput ^e

	;; kill-ring-save
	SendInput !w
	Sleep 100

	;; cancel find-file
	SendInput ^g

	resultP = %clipboard%
	;; OutputDebug,Clipboard content: %clipboard%
	StringReplace,curDir,resultP,/,\,All
	;; OutputDebug,Favmenu_DialogSetPath_Emacs returns: %curDir%
	return curDir
}

FavMenu_DialogSetPath_Emacs(path)
{
	SendInput ^g
	;; find-file
	SendInput ^x^f
	;; beginning-of-line, kill-line
	Sleep 100
	SendInput ^a^k
	Sleep 100
	
	SendInput %path%{ENTER}

	Sleep 100
}

