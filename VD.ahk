;Virtual Desktop Library
;Original by pmb6tz
;Modified by Hunter Oakes
;Original Here:
;https://github.com/pmb6tz/windows-desktop-switcher
;{Initiate
VD_Init(Wrap_Desktop := 0, Use_Labels := 0, Use_Names := 0){
	Global DesktopCount := 2        ; Windows starts with 2 desktops at boot
	Global CurrentDesktop := 1      ; Desktop count is 1-indexed (Microsoft numbers them this way)
	Global LastOpenedDesktop := 1
	global hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\Lib\VirtualDesktopAccessor.dll", "Ptr")
	global IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnDesktopNumber", "Ptr")
	global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
	global WrapDesktop := Wrap_Desktop
	global UseLabels := Use_Labels
	global UseNames := Use_Names
	VD_mapDesktopsFromRegistry()
}
;}
;{Map Desktops from Registry
VD_mapDesktopsFromRegistry() 
{
    global CurrentDesktop, DesktopCount

    ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
    IdLength := 32
    SessionId := VD_getSessionId()
    if (SessionId) {
        RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
        if (CurrentDesktopId) {
            IdLength := StrLen(CurrentDesktopId)
        }
    }

    ; Get a list of the UUIDs for all virtual desktops on the system
    RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
    if (DesktopList) {
        DesktopListLength := StrLen(DesktopList)
        ; Figure out how many virtual desktops there are
        DesktopCount := floor(DesktopListLength / IdLength)
    }
    else {
        DesktopCount := 1
    }

    ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
    i := 0
    while (CurrentDesktopId and i < DesktopCount) {
        StartPos := (i * IdLength) + 1
        DesktopIter := SubStr(DesktopList, StartPos, IdLength)
        OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.

        ; Break out if we find a match in the list. If we didn't find anything, keep the
        ; old guess and pray we're still correct :-D.
        if (DesktopIter = CurrentDesktopId) {
            CurrentDesktop := i + 1
            OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
            break
        }
        i++
    }
}
;}
;{Get Session ID
;
; This functions finds out ID of current session.
;
VD_getSessionId()
{
    ProcessId := DllCall("GetCurrentProcessId", "UInt")
    if ErrorLevel {
        OutputDebug, Error getting current process id: %ErrorLevel%
        return
    }
    OutputDebug, Current Process Id: %ProcessId%

    DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
    if ErrorLevel {
        OutputDebug, Error getting session id: %ErrorLevel%
        return
    }
    OutputDebug, Current Session Id: %SessionId%
    return SessionId
}
;}
;{Switch Desktop to Target Desktop
VD_switchDesktopToTarget(targetDesktop)
{
    ; Globals variables should have been updated via VD_updateGlobalVariables() prior to entering this function
    global CurrentDesktop, DesktopCount, LastOpenedDesktop

    ; Don't attempt to switch to an invalid desktop
    if (targetDesktop > DesktopCount || targetDesktop < 1 || targetDesktop == CurrentDesktop) {
        OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
        return
    }

    LastOpenedDesktop := CurrentDesktop

    ; Fixes the issue of active windows in intermediate desktops capturing the switch shortcut and therefore delaying or stopping the switching sequence. This also fixes the flashing window button after switching in the taskbar. More info: https://github.com/pmb6tz/windows-desktop-switcher/pull/19
    WinActivate, ahk_class Shell_TrayWnd

    ; Go right until we reach the desktop we want
    while(CurrentDesktop < targetDesktop) {
        Send {LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}
        CurrentDesktop++
		sleep 50
        OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
    }

    ; Go left until we reach the desktop we want
    while(CurrentDesktop > targetDesktop) {
        Send {LWin down}{LCtrl down}{Left down}{Lwin up}{LCtrl up}{Left up}
        CurrentDesktop--
		sleep 100
        OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
    }

    ; Makes the WinActivate fix less intrusive
    Sleep, 50
    VD_focusTheForemostWindow(targetDesktop)
	SetTimer, VD_DisplayDesktopName, -400
}
;}
;{Update Global Variables
VD_updateGlobalVariables() 
{
    ; Re-generate the list of desktops and where we fit in that. We do this because
    ; the user may have switched desktops via some other means than the script.
    VD_mapDesktopsFromRegistry()
}
;}
;{Switch Desktop by Number
VD_switchDesktopByNumber(targetDesktop)
{
    global CurrentDesktop, DesktopCount
    VD_updateGlobalVariables()
    VD_switchDesktopToTarget(targetDesktop)
}
;}
;{Switch to Last Opened Desktop
VD_switchDesktopToLastOpened()
{
    global CurrentDesktop, DesktopCount, LastOpenedDesktop
    VD_updateGlobalVariables()
    VD_switchDesktopToTarget(LastOpenedDesktop)
}
;}
;{Move to next right desktop
VD_switchDesktopToRight()
{
    global CurrentDesktop, DesktopCount, WrapDesktop
    VD_updateGlobalVariables()
	if (WrapDesktop){
		VD_switchDesktopToTarget(CurrentDesktop == DesktopCount ? 1 : CurrentDesktop + 1)
	}
	else{
		VD_switchDesktopToTarget(CurrentDesktop == DesktopCount ? CurrentDesktop : CurrentDesktop + 1)
	}
}
;}
;{Move to next left desktop
VD_switchDesktopToLeft()
{
    global CurrentDesktop, DesktopCount, WrapDesktop
    VD_updateGlobalVariables()
	if (WrapDesktop){
		VD_switchDesktopToTarget(CurrentDesktop == 1 ? DesktopCount : CurrentDesktop - 1)
	}
	else{
		VD_switchDesktopToTarget(CurrentDesktop == 1 ? CurrentDesktop : CurrentDesktop - 1)
	}
}
;}
;{Activate Foremost window on some desktop
VD_focusTheForemostWindow(targetDesktop) {
    foremostWindowId := VD_getForemostWindowIdOnDesktop(targetDesktop)
    if VD_isWindowNonMinimized(foremostWindowId) {
        WinActivate, ahk_id %foremostWindowId%
    }
}
;}
;{Check if window is not minimied
VD_isWindowNonMinimized(windowId) {
    WinGet MMX, MinMax, ahk_id %windowId%
    return MMX != -1
}
;}
;{Get Foremost Window On Some Desktop
VD_getForemostWindowIdOnDesktop(n)
{
    n := n - 1 ; Desktops start at 0, while in script it's 1
	global IsWindowOnDesktopNumberProc
    ; winIDList contains a list of windows IDs ordered from the top to the bottom for each desktop.
    WinGet winIDList, list
    Loop % winIDList {
        windowID := % winIDList%A_Index%
        windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, windowID, UInt, n)
        ; Select the first (and foremost) window which is in the specified desktop.
        if (windowIsOnDesktop == 1) {
            return windowID
        }
    }
}
;}
;{Move Active Window to New Desktop
VD_MoveCurrentWindowToDesktop(desktopNumber) {
    WinGet, activeHwnd, ID, A
	global MoveWindowToDesktopNumberProc
    DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, desktopNumber - 1)
	VD_switchDesktopByNumber(desktopNumber)
}
;}
;{Create New Desktop
;
; This function creates a new virtual desktop and switches to it
;
VD_createVirtualDesktop()
{
    global CurrentDesktop, DesktopCount
    Send, #^d
    DesktopCount++
    CurrentDesktop := DesktopCount
	SetTimer, VD_DisplayDesktopName, -400
	OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}
;}
;{Delete Current Desktop
;
; This function deletes the current virtual desktop
;
VD_deleteVirtualDesktop()
{
    global CurrentDesktop, DesktopCount, LastOpenedDesktop
    Send, #^{F4}
    if (LastOpenedDesktop >= CurrentDesktop) {
        LastOpenedDesktop--
    }
    DesktopCount--
    CurrentDesktop--
	SetTimer, VD_DisplayDesktopName, -400
	OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}
;}
;{Display Desktop Names
;
; This will display the name of the current desktop when it is activated
;
/*
UseLabels\UseNames	|0		|1		
				0	|A		|B
				1	|C		|D

Behavior A: No Labels Whatsoever
Behavior B: Only display labels when on Named desktops, labels are the names
Behavior C: Use Labels on All Desktops, Lables are all Desktop Numbers
Behavior D: Use Labels on All Desktops, Labels are Desktop Numbers, except when Desktops are named

*/
VD_DisplayDesktopName(){
	Global CurrentDesktop, UseLabels, UseNames
	SplashWidth := 140
	SplashWidth2 := 40
	Width := ((A_ScreenWidth-SplashWidth) / 2)
	Width2 := ((A_ScreenWidth-SplashWidth2) / 2)
	Height := A_ScreenHeight / 2
	Height2 := A_ScreenHeight / 2
	SleepTime := 500
	Desktop := Global Desktop%CurrentDesktop%Name
	sleep, 200
	if (UseLabels){
		if (UseNames){
			if (Desktop){
				SplashImage,, w%SplashWidth% x%Width% y%Height% b fs10, % Desktop
			}
			if (!Desktop){
				SplashImage,, w%SplashWidth2% x%Width2% y%Height2% b fs10, %CurrentDesktop%
			}	
		}
		if (!UseNames){
			SplashImage,, w%SplashWidth2% x%Width2% y%Height2% b fs10, %CurrentDesktop%
		}
	}
	if (!UseLabels){
		if (UseNames){
			if (Desktop){
				SplashImage,, w%SplashWidth% x%Width% y%Height% b fs10, % Desktop
			}
		}
	}
	Sleep, %SleepTime%
	SplashImage, Off
}
;}
;{Change Desktop Or Move Window
;
; This will move the window to the selected desktop if "key" is pressed, or just go to that desktop if it is not
;
VD_ChangeDesktopOrMoveWindow(num, key){
	If GetKeyState(key, "P"){
		VD_MoveCurrentWindowToDesktop(num)
	}
	else{
		VD_switchDesktopByNumber(num)
	}
}
;}
