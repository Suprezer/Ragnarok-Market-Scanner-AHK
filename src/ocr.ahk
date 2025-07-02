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
OCR(imagePath, psm := 11) {
    tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"
    outFile := StrReplace(imagePath, ".png") . ".txt"
    ; Whitelist numbers, comma, and space
    RunWait('"' tesseractPath '" "' imagePath '" "' outFile '" --oem 1 --psm ' psm ' -c thresholding_method=1 -c tessedit_char_whitelist=0123456789, ', , "Hide")
    return FileRead(outFile ".txt")
}

BinarizeImage(imagePath, threshold := 180) {
    pBitmap := Gdip_CreateBitmapFromFile(imagePath)
    width := Gdip_GetImageWidth(pBitmap)
    height := Gdip_GetImageHeight(pBitmap)
    ix := 0
    while ix < width {
        iy := 0
        while iy < height {
            ARGB := Gdip_GetPixel(pBitmap, ix, iy)
            r := (ARGB >> 16) & 0xFF
            g := (ARGB >> 8) & 0xFF
            b := ARGB & 0xFF
            gray := Round(0.299*r + 0.587*g + 0.114*b)
            color := (gray > threshold) ? 0xFFFFFFFF : 0xFF000000  ; White or Black
            Gdip_SetPixel(pBitmap, ix, iy, color)
            iy += 1
        }
        ix += 1
    }
    Gdip_SaveBitmapToFile(pBitmap, imagePath)
    Gdip_DisposeImage(pBitmap)
}

ParseListingRows(ocrText) {
    rows := StrSplit(ocrText, "`n")
    cleanRows := []
    for _, row in rows {
        row := Trim(row)
        row := StrReplace(row, ".", ",") ; Convert periods to commas
        row := RegExReplace(row, "[^0-9,\s]", "") ; Keep only numbers, commas, whitespace
        if (StrLen(row) > 0)
            cleanRows.Push(row)
    }
    return cleanRows
}