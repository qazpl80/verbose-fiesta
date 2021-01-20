#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#maxThreadsPerHotkey, 2
setKeyDelay, 50, 50
setMouseDelay, 50

toggle:=0
~*h::
toggle:=!toggle
If Toggle
{
	Click, Down
}
else
{
	Click, Up
}
return