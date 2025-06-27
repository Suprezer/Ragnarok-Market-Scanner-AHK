; Ragnarok Market Scanner - Simple GUI (AHK v2)
; Author: Jonas M. Olesen

; --- SQLite Integration ---
#Include ..\lib\Class_SQLiteDB.ahk
#Include ..\src\init_db.ahk

; Database initialization
try {
    InitDatabase()
} catch Error as e {
    MsgBox('Error initializing database: ' e.Message, 'Database Error', 'IconError')
}

RefreshItems() {
    items := []
    dbPath := A_ScriptDir "\..\market.db"
    db := SQLiteDB()
    if db.OpenDB(dbPath) {
        if db.GetTable("SELECT name FROM items ORDER BY name", &tb) && tb.HasRows {
            for row in tb.Rows
                items.Push(row[1])
        }
        db.CloseDB()
    }
    return items
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

ScanMarket(*) {
    MsgBox('Market scan feature coming soon!', 'Info', 'Iconi')
}

AddItem(*) {
    result := InputBox('Enter new item name:', 'Add Item', '')
    if !result.Result
        return
    newItem := result.Value
    if !newItem
        return
    db := SQLiteDB()
    dbPath := A_ScriptDir "\..\market.db"
    if db.OpenDB(dbPath) {
        if db.Exec("INSERT INTO items (name) VALUES (?)", newItem) {
            itemList.Delete()
            itemList.Add(RefreshItems())
        } else {
            MsgBox("Failed to add item (maybe duplicate name).", "Error", "IconError")
        }
        db.CloseDB()
    }
}

EditItem(*) {
    idx := itemList.Value
    if !idx
        return
    oldName := itemList.Text
    result := InputBox('Edit item name:', 'Edit Item', oldName,)
    if !result.Result
        return
    newName := result.Value
    if !newName || (newName = oldName)
        return
    db := SQLiteDB()
    dbPath := A_ScriptDir "\..\market.db"
    if db.OpenDB(dbPath) {
        if db.Exec("UPDATE items SET name = ? WHERE name = ?", newName, oldName) {
            itemList.Delete()
            itemList.Add(RefreshItems())
        } else {
            MsgBox("Failed to edit item (maybe duplicate name).", "Error", "IconError")
        }
        db.CloseDB()
    }
}

RemoveItem(*) {
    idx := itemList.Value
    if !idx
        return
    name := itemList.Text
    if MsgBox("Delete item '" name "'?", "Confirm") = "N"
        return
    db := SQLiteDB()
    dbPath := A_ScriptDir "\..\market.db"
    if db.OpenDB(dbPath) {
        if db.Exec("DELETE FROM items WHERE name = ?", name) {
            itemList.Delete()
            itemList.Add(RefreshItems())
        } else {
            MsgBox("Failed to remove item.", "Error", "IconError")
        }
        db.CloseDB()
    }
}
