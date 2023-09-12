#include <MsgBoxConstants.au3>
#include <ScreenCapture.au3>

; Press Esc to terminate script, Pause/Break to "pause"

Global $g_bPaused = False
$imagenumber=0

$aArray= WinGetPos('[Active]')
;Exit

HotKeySet("{PAUSE}", "HotKeyPressed")
HotKeySet("{ESC}", "HotKeyPressed")
HotKeySet("!a", "HotKeyPressed") ; Shift-Alt-d
HotKeySet("!s", "HotKeyPressed") ; overwritelast
While 1
    Sleep(100)
WEnd

Func HotKeyPressed()
   $fileout=@MyDocumentsDir & "\c2\"&StringFormat("%03d", $imagenumber)
    Switch @HotKeyPressed ; The last hotkey pressed.
        Case "{PAUSE}" ; String is the {PAUSE} hotkey.
            $g_bPaused = Not $g_bPaused
            While $g_bPaused
                Sleep(100)
                ToolTip('Script is "Paused"', 0, 0)
            WEnd
            ToolTip("")

        Case "{ESC}" ; String is the {ESC} hotkey.
            ;Exit
			            ;MsgBox($MB_SYSTEMMODAL, "", "This is a message.")
			$imagenumber=$imagenumber  +1;
			 ;_ScreenCapture_Capture(@MyDocumentsDir & "\"& StringFormat("%03d", $imagenumber) & ".png", 156, 344, 1402, 1046);
			 ConsoleWrite("taken1 "& $fileout&@CRLF)
			 _ScreenCapture_Capture($fileout & ".png", $aArray[0], $aArray[1], $aArray[0]+$aArray[2], $aArray[1]+$aArray[3]);

		 Case "!s" ; String is the {ESC} hotkey.
			$imagenumber=$imagenumber  -1;
			ConsoleWrite("stop ")

        Case "!a" ; String is the Shift-Alt-d hotkey.
            ;MsgBox($MB_SYSTEMMODAL, "", "This is a message.")
			$imagenumber=$imagenumber  +1;
			 ;_ScreenCapture_Capture(@MyDocumentsDir & "\"& StringFormat("%03d", $imagenumber) & ".png", 156, 344, 1402, 1046);
			 ConsoleWrite("taken2 " &$fileout&@CRLF)
			 _ScreenCapture_Capture($fileout & ".png", $aArray[1], $aArray[0]+$aArray[2], $aArray[1]+$aArray[3]);

			 ;ControlSend($hWin,"",$hControl,"{DOWN}")
			 Send("{DOWN}")

    EndSwitch
EndFunc   ;==>HotKeyPressed
