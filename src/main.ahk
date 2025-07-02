; Ragnarok Market Scanner - Requires (AHK v2)
; Author: Jonas M. Olesen

if !A_IsAdmin
{
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

#Include ..\lib\Class_SQLiteDB.ahk
#Include ..\src\init_db.ahk
#Include ..\src\item_db.ahk
#Include ..\src\scanner.ahk
#Include ..\src\utility.ahk

global logBox

; Database initialization
try {
    InitDatabase()
} catch Error as e {
    MsgBox('Error initializing database: ' e.Message, 'Database Error', 'IconError')
}

RefreshItems() {
    return GetAllItems()
}

items := RefreshItems()

alwaysOnTop := IniRead("settings.ini", "Options", "AlwaysOnTop", 0)
showConsoleLog := IniRead("settings.ini", "Options", "ShowConsoleLog", 1)

myGui := Gui()
myGui.AddButton('x20 y50 w80 h30', 'Add Item').OnEvent('Click', AddItem)
myGui.AddButton('x110 y50 w80 h30', 'Edit Item').OnEvent('Click', EditItem)
myGui.AddButton('x200 y50 w80 h30', 'Remove Item').OnEvent('Click', RemoveItem)

myGui.AddButton('x20 y220 w120 h30', 'Set Board Location').OnEvent('Click', SetMarketBoardLocation)
myGui.AddButton('x150 y220 w120 h30', 'Scan Market').OnEvent('Click', Scan)

itemList := myGui.AddListBox('x20 y90 w260 h120 vItemList', items)

alwaysOnTopBox := myGui.AddCheckBox('x200 y5 w120 h20', 'Always On Top')
alwaysOnTopBox.Value := alwaysOnTop
alwaysOnTopBox.OnEvent('Click', ToggleAlwaysOnTop)
if alwaysOnTop
    myGui.Opt('+AlwaysOnTop')

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := 'Ragnarok Market Scanner'

logBox := myGui.AddEdit('x20 y260 w260 h80 ReadOnly -WantReturn', "")
logBox.Visible := !!showConsoleLog
showLogBox := myGui.AddCheckBox('x200 y30 w120 h20', 'Console Log')
showLogBox.Value := showConsoleLog
showLogBox.OnEvent('Click', ToggleLogBox)

myGui.Show('w300 h380')

Log(msg) {
    global logBox
    if !IsSet(logBox)
        return
    logBox.Value := logBox.Value . msg . "`r`n"
    logBox.Focus()
    ; Scroll to the bottom
    SendMessage(0xB1, -1, -1, logBox.Hwnd)
    SendMessage(0xB7, 0, 0, logBox.Hwnd)
    ; Write to file with timestamp (`n)
    logFile := A_ScriptDir "\..\log.txt"
    FileAppend(Format("[{}] {}`n", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), msg), logFile, "UTF-8")
}

ToggleAlwaysOnTop(ctrl, *) {
    if ctrl.Value
        myGui.Opt('+AlwaysOnTop')
    else
        myGui.Opt('-AlwaysOnTop')
    IniWrite(ctrl.Value, "settings.ini", "Options", "AlwaysOnTop")
}


AddItem(*) {
    result := InputBox('Enter new item name:', 'Add Item', '',)
    if !result.Result
        return
    newItem := result.Value
    if !newItem
        return
    if AddItemToDB(newItem) {
        itemList.Delete()
        itemList.Add(GetAllItems())
    } else {
        MsgBox("Failed to add item (maybe duplicate name)")
    }
}

EditItem(*) {
    idx := itemList.Value
    if !idx
        return
    oldName := itemList.Text
    if !oldName
        return
    ; ToDo: Add oldName to InputBox later
    result := InputBox('Edit item name:', 'Edit Item')
    if !result.Result
        return
    newName := result.Value
    if !newName || (newName = oldName)
        return
    if EditItemInDB(oldName, newName) {
        itemList.Delete()
        itemList.Add(GetAllItems())
    } else {
        MsgBox("Failed to edit item (maybe duplicate name)")
    }
}

RemoveItem(*) {
    idx := itemList.Value
    if !idx
        return
    name := itemList.Text
    ;if MsgBox("Delete item '" name "'?", "Confirm", "YNIconQuestion") = "N"
    ;    return
    if RemoveItemFromDB(name) {
        itemList.Delete()
        itemList.Add(GetAllItems())
    } else {
        MsgBox("Failed to remove item.", "Error", "IconError")
    }
}

Scan(*) {
    Log("Starting market scan.")
    
    items := RefreshItems()

    ScanMarket(items)

    ; TODO: Check for completion
    Log("Market scan completed.")
}

ToggleLogBox(ctrl, *) {
    if ctrl.Value {
        logBox.Visible := true
        myGui.Show('w300 h380')
    } else {
        logBox.Visible := false
        myGui.Show('w300 h300')
    }
    IniWrite(ctrl.Value, "settings.ini", "Options", "ShowConsoleLog")
}

SetMarketBoardLocation(*) {
    MsgBox("After clicking OK, you will have 2 seconds to move your mouse to the market board location.")
    CoordMode("Mouse", "Screen")
    Sleep(2000)
    MouseGetPos(&locationX, &locationY)
    IniWrite(locationX, "settings.ini", "MarketBoard", "X")
    IniWrite(locationY, "settings.ini", "MarketBoard", "Y")
    Log("Market board location set to: " locationX ", " locationY)
}

ESC::ExitApp