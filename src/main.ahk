; Ragnarok Market Scanner - Requires (AHK v2)
; Author: Jonas M. Olesen

#Include ..\lib\Class_SQLiteDB.ahk
#Include ..\src\init_db.ahk
#Include ..\src\item_db.ahk
#Include ..\src\scanner.ahk

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

myGui := Gui()
myGui.AddButton('x20 y50 w80 h30', 'Add Item').OnEvent('Click', AddItem)
myGui.AddButton('x110 y50 w80 h30', 'Edit Item').OnEvent('Click', EditItem)
myGui.AddButton('x200 y50 w80 h30', 'Remove Item').OnEvent('Click', RemoveItem)
myGui.AddButton('x20 y220 w260 h30', 'Scan Market').OnEvent('Click', Scan)

itemList := myGui.AddListBox('x20 y90 w260 h120 vItemList', items)

alwaysOnTopBox := myGui.AddCheckBox('x200 y5 w120 h20', 'Always On Top')
alwaysOnTopBox.OnEvent('Click', ToggleAlwaysOnTop)

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := 'Ragnarok Market Scanner'

logBox := myGui.AddEdit('x20 y260 w260 h80 ReadOnly -WantReturn', "")
logBox.Visible := true
showLogBox := myGui.AddCheckBox('x200 y30 w120 h20', 'Console Log')
showLogBox.Value := 1
showLogBox.OnEvent('Click', ToggleLogBox)

myGui.Show('w300 h380')

Log(msg) {
    global logBox
    if !IsSet(logBox)
        return
    ; Add to GUI log
    logBox.Value := logBox.Value . msg . "`r`n"
    ; Write to file with timestamp (`n)
    logFile := A_ScriptDir "\..\log.txt"
    FileAppend(Format("[{}] {}`n", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), msg), logFile, "UTF-8")
}

ToggleAlwaysOnTop(ctrl, *) {
    if ctrl.Value
        myGui.Opt('+AlwaysOnTop')
    else
        myGui.Opt('-AlwaysOnTop')
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
}
