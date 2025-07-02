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
OCR(imagePath, psm := 11) { ; Use psm 11 for sparse text
    tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"
    outFile := StrReplace(imagePath, ".png") . ".txt"
    ; Whitelist numbers, comma, and space
    RunWait('"' tesseractPath '" "' imagePath '" "' outFile '" --oem 1 --psm ' psm ' -c thresholding_method=1 -c tessedit_char_whitelist=0123456789, ', , "Hide")
    return FileRead(outFile ".txt")
}

ParseListingRows(ocrText) {
    rows := StrSplit(ocrText, "`n")
    cleanRows := []
    for _, row in rows {
        row := Trim(row)
        ; Keep only numbers, commas, and whitespace
        row := RegExReplace(row, "[^0-9,\s]", "")
        if (StrLen(row) > 0)
            cleanRows.Push(row)
    }
    return cleanRows
}