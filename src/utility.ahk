#Requires AutoHotkey v2

F1::ShowMousePosition

ShowMousePosition() {
    ToolTip "Press ESC to stop"
    Loop {
        MouseGetPos &x, &y
        ToolTip "X: " x "  Y: " y
        Sleep 50
        if GetKeyState("Esc", "P")
            break
    }
    ToolTip
}