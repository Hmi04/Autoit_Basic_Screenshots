#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <ScreenCapture.au3>
#Include <Misc.au3>
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_HiDpi=Y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

If Not (@Compiled ) Then DllCall("User32.dll","bool","SetProcessDPIAware")

Global $iX1, $iY1, $iX2, $iY2, $aPos, $sMsg, $sBMP_Path
$iX1=0
$iY1=0
$iX2=@DeskTopWidth
$iY2=@DeskTopHeight
$imagefiletype=".png"

Local Const $sMessage = "Choose a filename."
$filediaglog = @MyDocumentsDir
$fileout =""
Global $g_bPaused = False
$imagenumber=0

HotKeySet("{PAUSE}", "HotKeyPressed")
HotKeySet("{ESC}", "HotKeyPressed")
HotKeySet("+!D", "HotKeyPressed") ; Shift-Alt-d
HotKeySet("+!J", "HotKeyPressed") ; Shift-Alt-j
HotKeySet("+!P", "HotKeyPressed") ; Shift-Alt-p
HotKeySet("!s", "HotKeyPressed") ; overwritelast

; Create GUI
$hMain_GUI = GUICreate("Capture", 320, 50,0,0)

$hRect_Button   = GUICtrlCreateButton("Mark",  10, 10, 40, 30)
$hFilename_Button   = GUICtrlCreateButton("Path",  60, 10, 40, 30)
$hCancel_Button = GUICtrlCreateButton("Cancel",    220, 10, 80, 30)

GUISetState()

While 1

    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE, $hCancel_Button
            ;FileDelete(@ScriptDir & "Rect.bmp")
            Exit
        Case $hRect_Button
            GUISetState(@SW_HIDE, $hMain_GUI)
            Mark_Rect()
            ; Capture selected area
            ;$sBMP_Path = @ScriptDir & "Rect.bmp"
            _ScreenCapture_Capture($sBMP_Path, $iX1, $iY1, $iX2, $iY2, False)
            GUISetState(@SW_SHOW, $hMain_GUI)
            ; Display image
            ;$hBitmap_GUI = GUICreate("Selected Rectangle", $iX2 - $iX1 + 1, $iY2 - $iY1 + 1, 100, 100)
            ;$hPic = GUICtrlCreatePic(@ScriptDir & "Rect.bmp", 0, 0, $iX2 - $iX1 + 1, $iY2 - $iY1 + 1)
            GUISetState()
		 Case $hFilename_Button
			        Local $filediaglog = FileSelectFolder($sMessage, @MyDocumentsDir, "Image (*.png)", $FD_PATHMUSTEXIST)
        If @error Then
                ; Display the error message.
                ;MsgBox($MB_SYSTEMMODAL, "", "No file was saved.")
				$filediaglog = @MyDocumentsDir
        Else
                Local $sFileName = StringTrimLeft($filediaglog, StringInStr($fileout, "\", $STR_NOCASESENSEBASIC, -1))

        EndIf
    EndSwitch

WEnd

; -------------

Func Mark_Rect()

    Local $aMouse_Pos, $hMask, $hMaster_Mask, $iTemp
    Local $UserDLL = DllOpen("user32.dll")

    ; Create transparent GUI with Cross cursor
    $hCross_GUI = GUICreate("Test", @DesktopWidth, @DesktopHeight - 20, 0, 0, $WS_POPUP, $WS_EX_TOPMOST)
    WinSetTrans($hCross_GUI, "", 8)
    GUISetState(@SW_SHOW, $hCross_GUI)
    GUISetCursor(3, 1, $hCross_GUI)

    Global $hRectangle_GUI = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, $WS_EX_TOOLWINDOW + $WS_EX_TOPMOST)
    GUISetBkColor(0x000000)

    ; Wait until mouse button pressed
    While Not _IsPressed("01", $UserDLL)
        Sleep(10)
    WEnd

    ; Get first mouse position
    $aMouse_Pos = MouseGetPos()
    $iX1 = $aMouse_Pos[0]
    $iY1 = $aMouse_Pos[1]

    ; Draw rectangle while mouse button pressed
    While _IsPressed("01", $UserDLL)

        $aMouse_Pos = MouseGetPos()

        $hMaster_Mask = _WinAPI_CreateRectRgn(0, 0, 0, 0)
        $hMask = _WinAPI_CreateRectRgn($iX1,  $aMouse_Pos[1], $aMouse_Pos[0],  $aMouse_Pos[1] + 1) ; Bottom of rectangle
        _WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
        _WinAPI_DeleteObject($hMask)
        $hMask = _WinAPI_CreateRectRgn($iX1, $iY1, $iX1 + 1, $aMouse_Pos[1]) ; Left of rectangle
        _WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
        _WinAPI_DeleteObject($hMask)
        $hMask = _WinAPI_CreateRectRgn($iX1 + 1, $iY1 + 1, $aMouse_Pos[0], $iY1) ; Top of rectangle
        _WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
        _WinAPI_DeleteObject($hMask)
        $hMask = _WinAPI_CreateRectRgn($aMouse_Pos[0], $iY1, $aMouse_Pos[0] + 1,  $aMouse_Pos[1]) ; Right of rectangle
        _WinAPI_CombineRgn($hMaster_Mask, $hMask, $hMaster_Mask, 2)
        _WinAPI_DeleteObject($hMask)
        ; Set overall region
        _WinAPI_SetWindowRgn($hRectangle_GUI, $hMaster_Mask)

        If WinGetState($hRectangle_GUI) < 15 Then GUISetState()
        Sleep(10)

    WEnd

    ; Get second mouse position
    $iX2 = $aMouse_Pos[0]
    $iY2 = $aMouse_Pos[1]

    ; Set in correct order if required
    If $iX2 < $iX1 Then
        $iTemp = $iX1
        $iX1 = $iX2
        $iX2 = $iTemp
    EndIf
    If $iY2 < $iY1 Then
        $iTemp = $iY1
        $iY1 = $iY2
        $iY2 = $iTemp
    EndIf

    GUIDelete($hRectangle_GUI)
    GUIDelete($hCross_GUI)
    DllClose($UserDLL)

EndFunc   ;==>Mark_Rect

Func HotKeyPressed()
   $fileout= $filediaglog &"\"&StringFormat("%03d", $imagenumber)
    Switch @HotKeyPressed ; The last hotkey pressed.
        Case "{PAUSE}" ; String is the {PAUSE} hotkey.
            $g_bPaused = Not $g_bPaused
            While $g_bPaused
                Sleep(100)
                ToolTip('Script is "Paused"', 0, 0)
            WEnd
            ToolTip("")

        Case "{ESC}" ; String is the {ESC} hotkey.
			screenshot(".png")
		 Case "!s" ; String is the {ESC} hotkey.
			$imagenumber=$imagenumber  -1;
			ConsoleWrite("stop ")
        Case "+!D" ; String is the Shift-Alt-d hotkey.
			screenshot(".jpg")
        Case "+!J" ; String is the Shift-Alt-d hotkey.
			screenshot(".jpg")
        Case "+!P" ; String is the Shift-Alt-d hotkey.
			screenshot(".png")

    EndSwitch
EndFunc   ;==>HotKeyPressed

Func screenshot($imagefiletype)
			$imagenumber=$imagenumber  +1;
			 ;_ScreenCapture_Capture(@MyDocumentsDir & "\"& StringFormat("%03d", $imagenumber) & $imagefiletype, 156, 344, 1402, 1046);
			 ConsoleWrite("taken1 "& $fileout&@CRLF)
			 _ScreenCapture_Capture($fileout & $imagefiletype, $iX1, $iY1, $iX2, $iY2);
EndFunc