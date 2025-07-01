#Requires AutoHotkey v2.0

#Include ..\lib\Gdip_All.ahk

; Ensuring GDI+ is initialized
if !Gdip_Startup()
{
    MsgBox "GDI+ failed to start."
    ExitApp
}

; Capture a region of the screen to an image file (requires GDI+)
CaptureRegion(x, y, w, h, outFile) {
    hBitmap := DllCall("User32.dll\GetDC", "ptr", 0, "ptr")
    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" (x+w-1) "|" (y+h-1))
    Gdip_SaveBitmapToFile(pBitmap, outFile)
    Gdip_DisposeImage(pBitmap)
    DllCall("User32.dll\ReleaseDC", "ptr", 0, "ptr", hBitmap)
}
 
; Tesseract OCR
OCR(imagePath, psm := 6) {
    tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"
    outFile := StrReplace(imagePath, ".png") . ".txt"
    RunWait('"' tesseractPath '" "' imagePath '" "' outFile '" --oem 1 --psm ' psm, , "Hide")
    return FileRead(outFile ".txt")
}

; Split OCR result into rows
ParseListingRows(ocrText) {
    return StrSplit(ocrText, "`n")
}