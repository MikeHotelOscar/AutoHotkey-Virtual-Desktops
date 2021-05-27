# AutoHotkey-Virtual-Desktops
This is a library plus a DLL that allows one to control Windows 10 Virtual Desktops using AutoHotkey.

Originally developed by Github user pmb6tz as a set of functions accomplishing the same goal, I have turned that into a [library](https://www.autohotkey.com/docs/Functions.htm#lib) that allows one to call these functions without an #include statement. Simply place both VD.ahk and VirtualDesktopAccessor.dll into an applicable Library folder, call the functions you desire, and voilà!

Please read the readme for the original [here](https://github.com/pmb6tz/windows-desktop-switcher) first

## In addition to the work done by pmb6tz I have added a few extra features:

Setup for the library's use is done simply by calling VD_Init(). VD_Init() has 3 parameters, all of which are optional and are binary. The first is Wrap_desktop, which allows the ability to move left on the first desktop to get to the last, and right on the last desktop to get to the first. The other two parameters, UseLabels and UseNames, in that order, allow one to provide a display that provides a name or number on a desktop when it becomes the active desktop. Names are provided by creating global variables in the Auto-Execute section of a script with the names of the desktops in the form Global Desktop(Number)Name := "SomeName". The variables create the following behavior when used in a particular way:

* Both 0: No labels at all
* UseLabels = 0 and UseNames = 1: Only display labels on named desktops, labels are the names provided
* UseLabels = 1 and UseNames = 0: Labels are displayed on all desktops, labels are desktop numbers
* Both 1: Labels are displayed on all desktops, labels are desktop numbers, unless a name is provided.

Using VD_ChangeDesktopOrMoveWindow(num, key) allows you to set any key as an extra modifier for a hotkey that will move the active window to the target desktop if it is held down, or simply move to the target desktop if it is not.
