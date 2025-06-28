#Requires AutoHotkey v2.0

; src/item_db.ahk

#Include ..\lib\Class_SQLiteDB.ahk

AddItemToDB(name) {
    dbPath := A_ScriptDir "\..\market.db"
    db := SQLiteDB()
    ok := false
    if db.OpenDB(dbPath) {
        ok := db.Exec("INSERT INTO items (name) VALUES ('?')", name)
        db.CloseDB()
    }
    return ok
}

GetAllItems() {
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

EditItemInDB(oldName, newName) {
    dbPath := A_ScriptDir "\..\market.db"
    db := SQLiteDB()
    ok := false
    if db.OpenDB(dbPath) {
        safeOld := StrReplace(oldName, "'", "''")
        safeNew := StrReplace(newName, "'", "''")
        ok := db.Exec("UPDATE items SET name = '" safeNew "' WHERE name = '" safeOld "'")
        db.CloseDB()
    }
    return ok
}

RemoveItemFromDB(name) {
    dbPath := A_ScriptDir "\..\market.db"
    db := SQLiteDB()
    ok := false
    if db.OpenDB(dbPath) {
        ; Helping to prevent SQL injection
        safeName := StrReplace(name, "'", "''")
        ok := db.Exec("DELETE FROM items WHERE name = '" safeName "'")
        db.CloseDB()
    }
    return ok
}
