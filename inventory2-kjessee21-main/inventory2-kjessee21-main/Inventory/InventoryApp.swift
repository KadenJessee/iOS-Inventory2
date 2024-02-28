//
//  InventoryApp.swift
//  Inventory
//
//  Created by Kaden Jessee on 6/19/23.
//

import SwiftUI
import Foundation
import SQLite3

@main
struct InventoryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class MyStuff: ObservableObject{
    @Published var items = [Item]()
    
    init(){
        readDatabase()
    }
    
    func readDatabase(){
        let databaseManager = DatabaseManager.shared
        items = databaseManager.fetchItems()
    }
    
    func writeDatabase(){
        let databaseManager = DatabaseManager.shared
        databaseManager.deleteAllItems()
        
        for item in items{
            databaseManager.insertItem(shortDescription: item.shortDescription, longDescription: item.longDescription)
        }
    }
}
