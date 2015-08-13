
FavMenu_DialogSetPath_GTK(path)
{
	OutputDebug,FavMenu_DialogSetPath_GTK called
	;; activate shortcut folder list 
;	SendInput,!r
;	Sleep 100
	;; activate the 3rd shortcut, to avoid 'Search' & 'Recent' (which prevents ctrl-l bringing up path entry)
;	SendInput {Down}{Down}
;	Sleep 100
	
	;;show the path entry
	SendInput,^l
	Sleep 100
	SendInput %path%  
	Sleep 100
	SendInput {End}{Enter}
}