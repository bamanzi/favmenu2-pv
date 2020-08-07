;----------------------------------------------------------------------------------
; Favmenu will call this function wenever it needs to send selected path to the FM
; This will only happen if Setup->Integration->System checkbox is ON.
;
; ARGUMENTS:	path, open in new tab/window flag
;
; NOTES:		This function is separated so AutoHotKey users are able to rewrite
;				it for file managers other then Total Commander or Windows Explorer
;
FavMenu_FM_Open( p_path, p_tab )
{
	global

	if FavMenu_fmExe contains TotalCmd.exe
		return FavMenu_FM_OpenTC( p_path, p_tab )
	
	if FavMenu_fmExe contains DoubleCmd.exe
		return FavMenu_FM_OpenDC( p_path, p_tab )

	if FavMenu_fmExe contains XYplorer
		return FavMenu_FM_OpenXYplorer( p_path, p_tab )
	
	if FavMenu_fmExe contains xplorer2
		return FavMenu_FM_OpenXplorer2( p_path, p_tab )
		
	FavMenu_FM_OpenExplorer( p_path )
}

;--------------------------------------------------------------------------

FavMenu_FM_OpenExplorer( p_path )
{
	global
	local a, b, exPID, einput

	a := WinExist("ahk_class ExploreWClass")
	b := WinExist("ahk_class CabinetWClass")
	if a
		c = ExploreWClass
	else
		c = CabinetWClass

	if (!a and !b)
		return FavMenu_FM_Run(p_path)
	
;	Windows Explorer exists (this will be executed if Explorer is File Manager
	WinActivate,ahk_class %c%

	;; overwrite global variable!!!
	FavMenu_dlgHWND := WinActive()
	
	FavMenu_GetExplorerInput(FavMenu_dlgHWND, Favmenu_dlgInput, FavMenu_msctls_progress32)
	FavMenu_DialogSetPath_Explorer( p_path )
}

;--------------------------------------------------------------------------
; Total Commander

FavMenu_FM_OpenTC(p_path, p_tab)
{	
	global FavMenu_fmExe, cm_editpath

	if not WinExist("ahk_class TTOTAL_CMD")
		 FavMenu_FM_Run()

	WinActivate,ahk_class TTOTAL_CMD
	FavMenu_dlgHwnd := WinActive()

	FavMenu_DialogSetPath_TC(p_path, p_tab)
}

;--------------------------------------------------------------------------
; Double Commander

FavMenu_FM_OpenDC(p_path, p_tab)
{	
	global FavMenu_fmExe, cm_editpath

	if not WinExist("ahk_class DClass")
		 FavMenu_FM_Run()

	WinActivate,ahk_class DClass
	FavMenu_dlgHwnd := WinActive()

	FavMenu_DialogSetPath_DoubleCommander(p_path, p_tab)
}

;--------------------------------------------------------------------------

FavMenu_FM_OpenXplorer2(p_path, p_tab)
{	
	global FavMenu_fmExe, cm_editpath

	if not WinExist("ahk_class ATL:ExplorerFrame")
		 FavMenu_FM_Run()

	WinActivate,ahk_class ATL:ExplorerFrame
	FavMenu_dlgHwnd := WinActive()
	FavMenu_DialogSetPath_Xplorer2(p_path, p_tab)
}

;--------------------------------------------------------------------------

FavMenu_FM_OpenXYplorer(p_path, p_tab)
{	
	global FavMenu_fmExe, cm_editpath

	;;FIXME: title
	if not WinExist("ahk_class ThunderRT6FormDC")
		 FavMenu_FM_Run()

	WinActivate,ahk_class ThunderRT6FormDC
	FavMenu_dlgHwnd := WinActive()
	FavMenu_DialogSetPath_XYplorer(p_path, p_tab)
}

;--------------------------------------------------------------------------
; Run the file manager with given arguments (defaults to nothing)
;
FavMenu_FM_Run( arg = "" )
{
	global FavMenu_fmExe

	Run %FavMenu_fmExe% %arg%, , ,PID
	WinWait ahk_pid %PID%, ,1	;this second is added cuz of AHK bug with explorer
}

FavMenu_FM_Locate(p_path, p_tab)
{
	global FavMenu_fmExe 

	if FavMenu_fmExe contains TotalCmd.exe
		return FavMenu_FM_LocateInTC( p_path, p_tab ) 

	if FavMenu_fmExe contains DoubleCmd.exe
		return FavMenu_FM_LocateInDC( p_path, p_tab ) 
	
	if FavMenu_fmExe contains XYplorer
		return FavMenu_FM_LocateInXYplorer( p_path, p_tab )

	if FavMenu_fmExe contains xplorer2
		return FavMenu_FM_LocateInXplorer2( p_path, p_tab )

	FavMenu_FM_LocateInExplorer( p_path, p_tab )
}

FavMenu_FM_LocateInExplorer( p_path, p_tab )
{
	;; meaning of 'p_tab' reversed here intended
	;; i.e. use 'explorer /select' if Shift not pressed
	if p_tab
	{
		;; just input the parent path (rather than the file)
		SplitPath, p_path, ,folder
		FavMenu_FM_OpenExplorer(folder)
	}
	else
		Run,explorer /select`,"%p_path%"
}

FavMenu_FM_LocateInTC( p_path, p_tab )
{
	global FavMenu_fmExe
	SplitPath, p_path, ,folder

	;FavMenu_FM_OpenTC(folder, false)

	if p_tab
		Run,%FavMenu_fmExe% /O /T /S "%p_path%", , ,PID
	else
		Run,%FavMenu_fmExe% /O /S "%p_path%", , ,PID
}

;; Double Commander
FavMenu_FM_LocateInDC( p_path, p_tab )
{
	global FavMenu_fmExe
	SplitPath, p_path, ,folder

	;FavMenu_FM_OpenTC(folder, false)

	if p_tab
		Run,%FavMenu_fmExe% -c -t "%p_path%"
	else
		Run,%FavMenu_fmExe% -c "%p_path%"
}

;;FIXME: Locate in existing instance
FavMenu_FM_LocateInXplorer2( p_path, p_tab )
{
	global FavMenu_fmExe
	; if p_tab
	; 	Run, %FavMenu_fmExe% "%p_path%", , ,PID
	; else
	;; FavMenu_DialogSetPath_Xplorer2 works fine with file (in addition to folder)
		FavMenu_FM_OpenXplorer2(p_path, p_tab)
}

;;FIXME: Locate in existing instance
FavMenu_FM_LocateInXYplorer( p_path, p_tab )
{
	global FavMenu_fmExe
	; if p_tab
	; 	Run, %FavMenu_fmExe% "%p_path%", , ,PID
	; else
		Run %FavMenu_fmExe% /select="%p_path%"
}

;--------------------------------------------------------------------------

FavMenu_AddAllFMCurrentPathsToMenu()
{
	local cnt  = 0 
	local array := Object()

	ifWinExist ahk_class TTOTAL_CMD
	{
		arr := FavMenu_DialogGetAllPaths_TC()
		cnt += FavMenu_AddFMCurrentPathsToMenu("TC", arr)
	}

	ifWinExist ahk_class CabinetWClass
	{
		arr := FavMenu_DialogGetAllPaths_Explorer()
		cnt += FavMenu_AddFMCurrentPathsToMenu("SYS", arr)
	}

	ifWinExist ahk_class ATL:ExplorerFrame
	{
		arr := FavMenu_DialogGetAllPaths_Xplorer2()
		cnt += FavMenu_AddFMCurrentPathsToMenu("X2", arr)
	}

	return cnt
}

;; TODO: add app icon here
FavMenu_AddFMCurrentPathsToMenu(app_prefix, paths)
{
	cnt := 0
	for index, curPath in paths
	{
		;; use only the directory name as menu label
		;StringGetPos e, curPath, \, R
		;StringGetPos idx, curPath, \, R, 1
		;if (idx != -1) and (idx != 2)
		;	StringMid curPath, curPath, idx+2, e-idx-1,

		Menu Favmenu_sub1, add, *[%app_prefix% &%cnt%] %curPath% , FavMenu_FullMenuHandlerDispatch
		cnt += 1
	}
	; add separator 
	Menu Favmenu_sub1, add
	cnt += 1

	return cnt
}