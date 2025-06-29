#Requires AutoHotkey v2.0

FindMarketBoard() {
    imagePath := A_WorkingDir "\assets\search_template.PNG"
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

    Log("Using image path: " imagePath)
    Log("Searching area: " x "," y " to " (x + w - 1) "," (y + h - 1))
    ; Search only within the game window
    if ImageSearch(&foundx, &foundy, x, y, x + w - 1, y + h - 1, "*50 " imagePath) = 0 {
        Log("Market board found at: " foundx ", " foundy)
        return { x: foundx, y: foundy }
    } else {
        Log("Market board not found.")
        return false
    }
}
