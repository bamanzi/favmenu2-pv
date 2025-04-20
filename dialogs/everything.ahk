;; GetPath for Everything
;; (No SetPath feature)

Favmenu_DialogIsType_Everything(hwnd, klass, title)
{
	If (klass = "EVERYTHING")
	{
		;FavMenu_dlgType := "EVERYTHING"
		return 1
	}
}

;; for Everything, 'current path' means the path of 1st SELETED ITEM
FavMenu_DialogGetPath_Everything()
{
	global FavMenu_dlgHWND

	;; method 1: get text of the statusbar
	;; FIXME: it won't work if user hide the statusbar
	;; FIXME: it won't work if user unchecked Options/General/View/Show selected item in statusbar
	ControlGetText, msg, msctls_statusbar321, ahk_id %FavMenu_dlgHWND%
	path1 := Favmenu_extract_path_from_title(msg)
	if (path1) {
		return path1
	}

	;; method 2: try to get the selected item and parse path from column Path
	;; FIXME: it won't work if Everything & FavMenu run on different user
	;; FIXME: it won't work if user hide column Path
	ControlGet,rows,List,Focused,SysListView321, ahk_id %FavMenu_dlgHWND%
	;OutputDebug,found Everything selected row(s): %rows%

	Loop Parse, rows, `n
	{
		cols := StrSplit(A_LoopField, A_Tab)
		Loop % cols.Length()
		{
			path := cols[A_Index]
			if SubStr(path, 2, 1)=":"
			{
				OutputDebug,found Everything column: COL%A_Index%: %path%
				return path
			}
		}
	}
	;TrayTip, "Could not get the folder name. Make sure you haven't hide the statusbar of Everything, and have ONE select in the list."
}

