#include dialogs\os_dialog.ahk
#include dialogs\explorer.ahk

#include dialogs\console.ahk
#include dialogs\cygwin.ahk
#include dialogs\msys.ahk

#include dialogs\total_commander.ahk
#include dialogs\free_commander.ahk
#include dialogs\xplorer2.ahk
#include dialogs\xyplorer.ahk
#include dialogs\double_commander.ahk
#include dialogs\winscp.ahk

#include dialogs\gtk.ahk
#include dialogs\emacs.ahk
;;TODO: 7-Zip FM

FavMenu_DialogHandlers_Init()
{
	global FavMenu_dlgTypes
	FavMenu_dlgTypes := Array()
	
	;; for each application/dialog here, there should be 3 functions
	;;	FavMenu_DialogIsType_XXX(hwnd, klass, title)	;; optional
	;;	FavMenu_DialogSetPath_XXX()			;; optional
	;;	FavMenu_DialogGetPath_XXX()			;; optional
	
	FavMenu_dlgTypes.Push("BFF")		; Browse for Folder
	FavMenu_dlgTypes.Push("OpenSave")	; Open/Save dialog
	FavMenu_dlgTypes.Push("Explorer")
	
	FavMenu_dlgTypes.Push("TC")		; Total Commander
	FavMenu_dlgTypes.Push("DoubleCommander") ; Double Commander
	FavMenu_dlgTypes.Push("Console")	; Double Commander
	FavMenu_dlgTypes.Push("Emacs")
	
	FavMenu_dlgTypes.Push("Msys")		; multiple front-end (mintty,cmd,console2...)
	FavMenu_dlgTypes.Push("Cygwin")		; multiple front-ends (mintty,cmd...)
	FavMenu_dlgTypes.Push("WinSCP")
	
	FavMenu_dlgTypes.Push("XYplorer")
	FavMenu_dlgTypes.Push("Xplorer2")
	FavMenu_dlgTypes.Push("FreeCommander")
	
	FavMenu_dlgTypes.Push("GTK")

	
}

; Explorer is seen as dialog if there is another app set as a file manager
; or as a File Manager if not. 
; If Explorer is current File Manager don't report it as a dialog.
;
FavMenu_DialogGetActive(hw=0)
{	
	global Favmenu_dlgHwnd, FavMenu_dlgTypes, FavMenu_dlgType

	WinGet, Favmenu_dlgHwnd, ID, A
	WinGetClass, class, ahk_id %Favmenu_dlgHwnd%
	WinGetTitle, title, ahk_id %Favmenu_dlgHwnd%
	OutputDebug,FaveMenu_DialogGetActive: class=|%class%|, title=|%title%|
	
	;; FIXME: special handling
	if FavMenu_IsOpenSave( Favmenu_dlgHwnd )
			return 1
	
	
	If (class = "mintty") Or (SubStr(class, 1, 4) = "rxvt")
	{
		WinGet,procpath,ProcessPath,ahk_id %Favmenu_dlgHwnd%
		OutputDebug,process path=%procpath%
		
		if procpath Contains \cygwin
		{
			FavMenu_dlgType := "Cygwin"
		} else {
			;; FIXME: what if mintty for WSL?
			FavMenu_dlgType := "Msys"
		}
		return 1
	}

	;;MobaXterm (FIXME: besides Cygwin session, current session could also be CMD session or SSH session)
	if  (class = "TMobaXtermForm") or (class = "TFormDetachedTab")
	{
		;;FIXME: this is 100% accurate, but in most cases it works, as by default Cygwin would update path to title
		;; title example  '2. /home/mobaxterm'	'6. /drives/d
		if title contains MobaXterm,. /
		{
			FavMenu_dlgType := "Cygwin"
			return 1
		} else 
		;; it may be SSH session, but we don't need FavMenu2 on SSH session
		{
			;; FIXME: what if WSL?
			FavMenu_dlgType := "Console"
			return 1
		}
	}

	Loop % FavMenu_dlgTypes.Length()
	{
		dlgType := FavMenu_dlgTypes[A_Index]
		funcName := "Favmenu_DialogIsType_" . dlgType
		fn := Func(funcName)
		if fn.Name
		{
			okey := fn.Call(Favmenu_dlgHwnd, class, title)
			OutputDebug,INFO: Function '%funcName%' returns '%okey%'
			if okey
			{
				FavMenu_dlgType := dlgType
				return 1
			}
		} else {
			OutputDebug,WARN: Function '%funcName%' not exist
		}
	}

	Favmenu_dlgType := "System"
	Favmenu_dlgHwnd := 0
	return 0
}


FavMenu_DialogGetPath()
{
	global Favmenu_dlgType, FavMenu_dlgTypes
	OutputDebug,FavMenu_DialogGetPath called with Favmenu_dlgType = %Favmenu_dlgType%`n


	if Favmenu_dlgType = OpenSave
		return Favmenu_DialogGetPath_OS()

	dlgType := FavMenu_dlgType
	funcName := "Favmenu_DialogGetPath_" . dlgType
	fn := Func(funcName)
	if fn.Name
	{
		path := fn.Call()
		OutputDebug,INFO: Function '%funcName%' returns '%path%'
		if path
			return path
	} else {
		OutputDebug,WARN: Function '%funcName%' not exist
	}

	return Favmenu_DialogGetPath_fromTitle()
}

FavMenu_DialogSetPath(path, bTab = false)
{
	global FavMenu_dlgType
	OutputDebug,FavMenu_DialogSetPath called with Favmenu_dlgType = %Favmenu_dlgType%

	if FavMenu_dlgType contains OpenSave,Office03
	{
		FavMenu_DialogSetPath_OpenSave(path)
		return
	}
	
	dlgType := FavMenu_dlgType
	funcName := "Favmenu_DialogSetPath_" . dlgType
	fn := Func(funcName)
	if fn.Name
	{
		OutputDebug,INFO: Function '%funcName%' dynamic calling...
		fn.Call(path, bTab)
	} else {
		OutputDebug,WARN: Function '%funcName%' not exist
	}
}

;--------------------------------------------------------------------------

Favmenu_DialogGetPath_fromTitle()
{
	;;for other applications/dialogs, try to parse title
	Local title
	WinGetActiveTitle, title
	OutputDebug, try to parse directory from title: %title%`n
	If title contains :\,\\
	{	
		local fstart, fend1, fend2, fend3, curDir
		fstart := InStr(title, ":\") -1
		if fstart <=0
		{
			fstart := InStr(title, "\\")
			if fstart <=0
				return
		}
		
		fend1 := InStr(title, " - ", fstart + 2) ;; mostly used
		fend2 := InStr(title, " * ", fstart + 2) ;; SciTE (SciTE4AHK)
		fend2 := InStr(title, "]",   fstart + 2)
		
		local fname1, fname2, fname3, fname4
		fname1 := SubStr(title, fstart, fend1 - fstart)
		fname2 := SubStr(title, fstart, fend2 - fstart)
		fname3 := SubStr(title, fstart, fend2 - fstart)
		fname4 := SubStr(title, fstart)
		
		OutputDebug `nDialogGetPath_FromTitle: fname1=%fname1%`nfname2=%fname2%`nfname3=%fname3%`n
		If FileExist(fname1) 
			curDir := fname1
		else if FileExist(fname2)
			curDir := fname2
		else if FileExist(fname3)
			curDir := fname3
		else if FileExist(fname4)
			curDir := fname4
		else
			return
		
		;; if it is not a directory
		If InStr(FileExist(curDir), "D")<=0
		{
			Splitpath,curDir,,dirpart
			;; add a trailing slash as SplitPath would return 'd:' for file 'd:\test.txt'
			if (StrLen(dirpart) = 2)
				dirpart = %dirpart%\
			return dirpart
		}
		else
			return curDir
	}
}

