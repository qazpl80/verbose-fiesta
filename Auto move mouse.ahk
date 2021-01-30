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

while (toggle =1)
{
	MouseMove, 20, 30, 50, R, Right ;h or Send, {RButton} ; ends an right click
	Sleep, 250 ; every 0.25 Seconds
	MouseMove, -20, -30, 50, R
	Sleep, 250 ; every 0.25 Seconds
}
return