;--------------------------------------------------------------------------
; set left and right panel and return source
;
FavMenu_GetTCPanels( ByRef pLeft, ByRef pRight)
{
	WinGetTitle, tcTitle, ahk_class TTOTAL_CMD
 	if tcTitle not contains 6.5 AND tcTitle not contains 7.0
   	{
		ControlGetText pLeft,  TPathPanel1, ahk_class TTOTAL_CMD
		ControlGetText pRight, TPathPanel2, ahk_class TTOTAL_CMD
	}
	else
	{
		ControlGetText pLeft,  TMyPanel5, ahk_class TTOTAL_CMD
		ControlGetText pRight, TMyPanel9, ahk_class TTOTAL_CMD
	}

	StringReplace pLeft, pLeft, *.*
	StringReplace pRight, pRight, *.*
}

;---------------------------------------------------------------------------

FavMenu_GetCurrentTCDir()
{
	WinGetActiveTitle,tcTitle
	Loop,10 {
		ControlGetText path, TMyPanel%A_Index%, ahk_class TTOTAL_CMD
		StringRight, tail, path, 1
		IfEqual, tail, >
		{
			FileAppend, found file path on TMyPanel%A_Index%: %path%`n,*
			src = %path%
			break
		} 
	  }

	StringReplace src, src, >
	return src
}


;---------------------------------------------------------------------------

FavMenu_SendTCCommand(cmd, wait=1)
{
	if (wait)
		SendMessage 1075, cmd, 0, , ahk_class TTOTAL_CMD
	else
		PostMessage 1075, cmd, 0, , ahk_class TTOTAL_CMD
}
