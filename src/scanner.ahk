#Requires AutoHotkey v2.0

FindMarketBoard() {
    imagePath := A_WorkingDir "\assets\search_template.png"
    ; Check if the image file exists
    if !FileExist(imagePath) {
        Log("Image file not found: " imagePath)
        return
    }
    ; Set coordinate mode to screen
    CoordMode("Pixel", "Screen")
    CoordMode("Mouse", "Screen")

    ; Fetch game window position
    gameWindow := "ahk_exe ragexe.exe"
    if !WinExist(gameWindow) {
        Log("Game window not found: " gameWindow)
        return
    }
    WinGetPos(&x, &y, &w, &h, gameWindow)

    foundx := 0
    foundy := 0

    ;ShowTemplateImage(imagePath)

    Log("Using image path: " imagePath)
    Log("Searching area: " x "," y " to " (x + w - 1) "," (y + h - 1))
    ; Search only within the game window
    if ImageSearch(&foundx, &foundy, x, y, x + w - 1, y + h - 1, imagePath) {
        ; Adjusting for corner of button not being interactive
        foundx += 5
        foundy += 5
        Log("Market board found at: " foundx ", " foundy)
        MouseMove(foundx, foundy, 0)
    } else {
        Log("Market board not found.")
        return false
    }

    ; Offsets for the search bar relative to the found template
    searchBoxX := foundx - 292
    searchBoxY := foundy - 16
    Log("Search box coordinates: " searchBoxX ", " searchBoxY)

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

CloseMarketBoard() {
    Send("{Esc}") ; Close the market board
    Sleep(500) ; Wait for the market board to close
}

ScanMarket(itemList) {

}
