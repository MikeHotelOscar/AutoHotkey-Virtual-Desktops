# AutoHotkey-Virtual-Desktops
This is a library plus a DLL that allows one to control Windows 10 Virtual Desktops using AutoHotkey.

Originally developed by Github user pmb6tz as a set of functions accomplishing the same goal, I have turned that into a library (https://www.autohotkey.com/docs/Functions.htm#lib) that allows one to call these functions without an #include statement. Simply place both VD.ahk and VirtualDesktopAccessor.dll into an applicable Library folder, call the functions you desire, and voilà!

Please read the readme for the original here first:

https://github.com/pmb6tz/windows-desktop-switcher

## In addition to the work done by pmb6tz I have added a few extra features:

Setup for the library's use is done simply by calling VD_Init() or VD_InitNoWrap() in a script's Auto-Execute section. The only difference between the two is that VD_InitNoWrap will not allow you to "wrap around" when moving left and right among desktops. In other words, if you have 6 desktops, you cannot use VD_switchDesktopToRight() to move to desktop 1 from desktop 6, nor can you use VD_switchDesktopToLeft() to move to desktop 1 to desktop 6.

Using VD_ChangeDesktopOrMoveWindow(num, key) allows you to set any key as an extra modifier for a hotkey that will move the active window to the target desktop if it is held down, or simply move to the target desktop if it is not.

During the Auto-Execute section of a script, you can define a number of desktop names in the form of Global Desktop(Number)Name := "SomeName", like Global Desktop1Name := "SomeName", and as long as Desktop1Name is not empty, the name of that desktop will be displayed briefly after changing to it. 
