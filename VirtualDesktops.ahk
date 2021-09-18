#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#InstallKeybdHook ;Allows Tracking of keypresses, useful for debugging
#UseHook On ;forces the use of keyboard hooks in hotkey execution
#NoTrayIcon
#WinActivateForce
#singleinstance force
SetTitleMatchMode 2
GroupAdd, ThisScript, %A_ScriptName% ;used to restart the script on saving it
;{AutoExecute
VD_Init(0,1,1)
global Desktop1Name := "Games"
global Desktop2Name := "Media"
global Desktop3Name := "Communication"
global Desktop4Name := "Work 1"
global Desktop5Name := "Work 2"
global Desktop6Name := "Work 3"
;}
;{Hotkeys
NumpadEnter & Numpad1::VD_ChangeDesktopOrMoveWindow(1, "NumpadAdd")
NumpadEnter & Numpad2::VD_ChangeDesktopOrMoveWindow(2, "NumpadAdd")
NumpadEnter & Numpad3::VD_ChangeDesktopOrMoveWindow(3, "NumpadAdd")
NumpadEnter & Numpad4::VD_ChangeDesktopOrMoveWindow(4, "NumpadAdd")
NumpadEnter & Numpad5::VD_ChangeDesktopOrMoveWindow(5, "NumpadAdd")
NumpadEnter & Numpad6::VD_ChangeDesktopOrMoveWindow(6, "NumpadAdd")
NumpadEnter & Numpad7::VD_ChangeDesktopOrMoveWindow(7, "NumpadAdd")
NumpadEnter & Numpad8::VD_ChangeDesktopOrMoveWindow(8, "NumpadAdd")
NumpadEnter & Numpad9::VD_ChangeDesktopOrMoveWindow(9, "NumpadAdd")
NumpadEnter & NumpadSub::VD_switchDesktopToLastOpened()
NumpadEnter & Right::VD_switchDesktopToRight()
NumpadEnter & Left::VD_switchDesktopToLeft()
NumpadEnter & Down::VD_deleteVirtualDesktop()
NumpadEnter & Up::VD_createVirtualDesktop()
NumpadAdd::
if GetKeyState("NumpadEnter", "P"){
	Return
}
else{
	send, {NumpadAdd}
}
return
NumpadEnter::NumpadEnter
#if WinActive("ahk_group ThisScript")
~^s::
TitleMatch := A_TitleMatchMode
SetTitleMatchMode 2	
Tooltip, Reloading updated script %A_ScriptName%
Sleep, 1000
Reload
SetTitleMatchMode, %TitleMatch%
return
#if
;}