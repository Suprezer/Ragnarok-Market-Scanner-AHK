#Requires AutoHotkey v2.0

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
    Sleep(1000)

    searchBoxX := coords.searchBoxX
    searchBoxY := coords.searchBoxY
    searchButtonX := coords.searchButtonX
    searchButtonY := coords.searchButtonY

    for item in itemList {
        Log("Scanning item: " item)

        OpenMarketBoard()

        MouseMove(searchBoxX, searchBoxY, 0)
        ClickLButton()
        Send(item)
        Sleep(100)

        MouseMove(searchButtonX, searchButtonY, 0)
        ClickLButton()
        Sleep(5000) ; Testing
        ; TODO: Capture price(s) for the item
    }
        ;*/
}