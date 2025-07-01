#Requires AutoHotkey v2.0

#Include ..\src\ocr.ahk

FindMarketBoard() {
    imagePath := A_WorkingDir "\assets\search_template.png"
    if !FileExist(imagePath) {
        Log("Image file not found: " imagePath)
        return false
    }

    CoordMode("Pixel", "Screen")
    CoordMode("Mouse", "Screen")
    gameWindow := "ahk_exe ragexe.exe"

    if !WinExist(gameWindow) {
        Log("Game window not found: " gameWindow)
        return false
    }
    WinGetPos(&x, &y, &w, &h, gameWindow)
    foundx := 0
    foundy := 0

    ;Log("Using image path: " imagePath)
    if ImageSearch(&foundx, &foundy, x, y, x + w - 1, y + h - 1, imagePath) {
        foundx += 5
        foundy += 5
        Log("Market board found at: " foundx ", " foundy)
        ;MouseMove(foundx, foundy, 0)
    } else {
        Log("Market board not found.")
        return false
    }

    searchBoxX := foundx - 292
    searchBoxY := foundy - 16
    Log("Search box coordinates: " searchBoxX ", " searchBoxY)

    return {
        searchBoxX: searchBoxX,
        searchBoxY: searchBoxY,
        searchButtonX: foundx,
        searchButtonY: foundy
    }
}

; // Function to display the template image in a GUI for testing
ShowTemplateImage(imagePath) {
    if !FileExist(imagePath) {
        MsgBox "Image not found: " imagePath
        return
    }
    previewGui := Gui()
    previewGui.Title := "Template Preview"
    previewGui.AddPicture(, imagePath) ; Adjust width as needed
    previewGui.Show("AutoSize Center")
}

ClickLButton() {
    Send("{LButton Down}")
    Sleep(30)
    Send("{LButton Up}")
}

CloseMarketBoard() {
    Send("{Esc}")
    Sleep(250)
}

OpenMarketBoard() {
    CoordMode("Mouse", "Screen")
    marketBoardLocationx := IniRead("settings.ini", "MarketBoard", "X", 0)
    marketBoardLocationy := IniRead("settings.ini", "MarketBoard", "Y", 0)

    MouseMove(marketBoardLocationx, marketBoardLocationy, 0)

    WinActivate("ahk_exe ragexe.exe")
    ClickLButton()
    Sleep(500)
}

ScanMarket(itemList) {
    CoordMode("Mouse", "Screen")
    results := []

    Log("Preparing Market board for scanning...")
    OpenMarketBoard()

    coords := FindMarketBoard()
    if (!coords) {
        Log("Issue encountered during startup.")
        return
    }

    ;CloseMarketBoard()
    Log("Market board fully prepared.")
    Sleep(300)

    searchBoxX := coords.searchBoxX
    searchBoxY := coords.searchBoxY
    searchButtonX := coords.searchButtonX
    searchButtonY := coords.searchButtonY

    ; Item listing region
    itemListingRegionX := searchButtonX -80
    itemListingRegionY := searchButtonY + 37
    ;Log("searchButtonX: " searchButtonX ", searchButtonY: " searchButtonY)
    ;Log("Item listing region: " itemListingRegionX ", " itemListingRegionY)

    for item in itemList {
        Log("Scanning item: " item)

        OpenMarketBoard()

        MouseMove(searchBoxX, searchBoxY, 0)
        ClickLButton()
        Send(item)
        Sleep(100)

        MouseMove(searchButtonX, searchButtonY, 0)
        ClickLButton()
        Sleep(1500)

        imagePath := A_ScriptDir "\item_Listing.png"
        CaptureRegion(itemListingRegionX, itemListingRegionY, -1099, -338, A_ScriptDir "\item_listing.png")

        ocrText := OCR(A_ScriptDir "\item_listing.png", 6)
        rows := ParseListingRows(ocrText)
        for i, row in rows {
            Log("Row " i ": " row)
        }

        Sleep(500)
    }
}