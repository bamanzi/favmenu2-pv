;---------------------------------------------------------------------------
; Some global actions provided by FavMenu

FavMenu_AddCurrentDir()
{
	global
	local name, idx, curDir, prefix, width

	curDir := FavMenu_DialogGetPath()
	if curDir =
	{
		MsgBox Can not get the folder name.`nYou probably selected virtual folder.
		return
	}

	;check for errors reported by OpenSave dialogs (starting with :)
	StringLeft idx, curDir, 1
	if (idx = ":")
	{
		StringMid curDir, curDir, 2, 256
		MsgBox, 16, %Favmenu_title%, Can not add this folder`n`n%curDir%
		return false
	}

	;get the Title
	StringGetPos idx, curDir, \, R
	if (idx != -1) and ( idx != 2 )
		StringMid name, curDir, idx+2, 256
	else name := curDir

	;determine width of the input box
	width := StrLen(curDir)*8
	if width < 100
		width := 200
	if width > 600
		width := 600

	InputBox name, %FavMenu_title%, Specify new title for the folder:`n%curDir%,, %width%, 150, , , , ,%name%
	if (ErrorLevel)
		return false

	; add ALT 0160 if - is first char
	StringLeft idx, name, 1
	if idx = -
			prefix := ">"
	
	;write to ini
	IniWrite %prefix%%name%,	%FavMenu_fmIni%, DirMenu, menu%FavMenu_mnuCnt%
	IniWrite cd %curDir%,		%FavMenu_fmIni%, DirMenu, cmd%FavMenu_mnuCnt%

	return true
}

FavMenu_CopyCurrentPath()
{
	local curDir

	curDir := FavMenu_DialogGetPath()
	if curDir =
	{
		MsgBox Can not get the folder name.`nYou probably selected virtual folder.
		return
	}

	clipboard = %curDir%
	TrayTip,FavMenu2: copy current path,%curDir%
}

FavMenu_CommandPromptHere()
{
	curDir := FavMenu_DialogGetPath()

	If curDir = 
	{
		MsgBox Can not get the folder name.`nYou probably selected virtual folder.
		return
	}

	Run,cmd /k "cd /d `%cd`%",%curDir%
}

FavMenu_OpenCurrentPathInFM()
{
	curDir := FavMenu_DialogGetPath()

	If curDir = 
	{
		MsgBox Can not get the folder name.`nYou probably selected virtual folder.
		return
	}

	FavMenu_FM_Open(curDir, false)
}

;---------------------------------------------------------------------------

FavMenu_ShellExecute(ppath)
{
	global Favmenu_title

	Run %ppath%, ,UseErrorLevel
	if (ErrorLevel = "ERROR")
		MsgBox, 64, %Favmenu_title%, Invalid menu item. Command can not be executed:`n%ppath%

	return
}