//
//  Database Manager.swift
//  Inventory
//
//  Created by Kaden Jessee on 7/13/23.
//

import Foundation
import SQLite3

class DatabaseManager{
    static let shared = DatabaseManager()
    private var database: OpaquePointer?
    
    private init(){
        openDatabase()
        createTable()
    }
    
    private func openDatabase(){
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Inventory.sqlite")
        
        if sqlite3_open(fileURL.path, &database) != SQLITE_OK{
            print("Error opening database")
        }
    }
    
    private func createTable() {
            let createTableQuery = """
            CREATE TABLE IF NOT EXISTS Items(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                shortDescription VARCHAR,
                longDescription VARCHAR
            );
            """
            
            if sqlite3_exec(database, createTableQuery, nil, nil, nil) != SQLITE_OK {
                print("Error creating table")
            }
        }
        
        func insertItem(shortDescription: String, longDescription: String) {
            let insertQuery = """
            INSERT INTO Items (shortDescription, longDescription)
            VALUES (?, ?);
            """
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(database, insertQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (shortDescription as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 2, (longDescription as NSString).utf8String, -1, nil)
                
                if sqlite3_step(statement) != SQLITE_OK {
                    print("Error inserting item")
                }
            }
            sqlite3_finalize(statement)
        }
        
        func deleteAllItems() {
            let deleteQuery = "DELETE FROM Items;"
            
            if sqlite3_exec(database, deleteQuery, nil, nil, nil) != SQLITE_OK {
                print("Error deleting items")
            }
        }
        
        func fetchItems() -> [Item] {
            let selectQuery = "SELECT * FROM Items ORDER BY id ASC;"
            var items: [Item] = []
            
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(database, selectQuery, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let shortDescription = String(cString: sqlite3_column_text(statement, 1))
                    let longDescription = String(cString: sqlite3_column_text(statement, 2))
                    
                    let item = Item(shortDescription: shortDescription, longDescription: longDescription)
                    items.append(item)
                }
            }
            
            sqlite3_finalize(statement)
            
            return items
        }
}
