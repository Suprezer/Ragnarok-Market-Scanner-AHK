; Initializes the SQLite database for the market scanner
#Include ..\lib\Class_SQLiteDB.ahk

InitDatabase() {
    dbPath := A_ScriptDir "\..\market.db"
    db := SQLiteDB()

    if db.OpenDB(dbPath) {
        ; Create the items table if it doesn't exist
        db.Exec(
            "CREATE TABLE IF NOT EXISTS items (" 
            . "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            . "name TEXT UNIQUE)"
        )
        ; Create the prices table if it doesn't exist
        db.Exec(
            "CREATE TABLE IF NOT EXISTS prices (" 
            . "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            . "item_id INTEGER, "
            . "price INTEGER, "
            . "timestamp TEXT, "
            . "FOREIGN KEY(item_id) REFERENCES items(id))"
        )
        db.CloseDB()
    } else {
        MsgBox("Failed to open database: " db.ErrorMsg)
    }
}

InitDatabase()
