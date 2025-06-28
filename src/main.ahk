; Ragnarok Market Scanner - Simple GUI (AHK v2)
; Author: Jonas M. Olesen

; --- SQLite Integration ---
#Include ..\lib\Class_SQLiteDB.ahk
#Include ..\src\init_db.ahk
#Include ..\src\item_db.ahk

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
myGui.AddText('x20 y10 w200 h30', 'Ragnarok Market Scanner')
myGui.AddButton('x20 y50 w80 h30', 'Add Item').OnEvent('Click', AddItem)
myGui.AddButton('x110 y50 w80 h30', 'Edit Item').OnEvent('Click', EditItem)
myGui.AddButton('x200 y50 w80 h30', 'Remove Item').OnEvent('Click', RemoveItem)
itemList := myGui.AddListBox('x20 y90 w260 h120 vItemList', items)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := 'Market Scanner'
myGui.Show('w300 h240')

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
        MsgBox("Failed to add item (maybe duplicate name).", "Error", "IconError")
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

ScanMarket(*) {
    MsgBox('Market scan feature coming soon!', 'Info', 'Iconi')
}

