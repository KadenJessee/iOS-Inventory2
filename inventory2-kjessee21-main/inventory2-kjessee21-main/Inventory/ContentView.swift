//
//  ContentView.swift
//  Inventory2
//
//  Created by Kaden Jessee on 6/19/23.
//

import SwiftUI
import SQLite3
import Foundation

struct Item: Identifiable {
    let id = UUID()
    var shortDescription: String
    var longDescription: String
}

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    //@State private var items: [Item] = []
    @StateObject private var arr = MyStuff()
    @State private var isPresentingAddSheet = false
    //@State private var selectedItem: Item? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(arr.items) { item in
                    NavigationLink(destination: EditItemView(item: item, items: $arr.items)) {
                        VStack(alignment: .leading) {
                            Text(item.shortDescription)
                                .font(.headline)
                            Text(item.longDescription)
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Inventory")
            .navigationBarItems(trailing:
                Button(action: {
                    isPresentingAddSheet = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isPresentingAddSheet) {
                AddItemView(isPresented: $isPresentingAddSheet, items: $arr.items)
            }
        }
        .onChange(of: scenePhase) {newPhase in
            if newPhase == .active{
                arr.readDatabase()
            } else if newPhase == .inactive{
                arr.writeDatabase()
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        arr.items.remove(atOffsets: offsets)
    }
}

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    @Binding var items: [Item]
    @State private var shortDescription = ""
    @State private var longDescription = ""
    
    var body: some View {
        NavigationView {
            Form {
                
                TextField("Short Description", text: $shortDescription)
                    .accessibilityIdentifier("addShortDescription")
                
                TextField("Long Description", text: $longDescription)
                    .accessibilityIdentifier("addLongDescription")
            }
            .padding()
            .navigationTitle("Add New Item")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing: Button(action: {
                    saveItem()
                }) {
                    Text("Save")
                }
            )
        }
    }
    
    private func saveItem() {
        let newItem = Item(shortDescription: shortDescription, longDescription: longDescription)
        items.append(newItem)
        isPresented = false
        presentationMode.wrappedValue.dismiss()
        clearNewDialogFields()
    }
    
    private func clearNewDialogFields() {
        shortDescription = ""
        longDescription = ""
    }
}

struct EditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var editedItem: Item
    @Binding var items: [Item]
    
    init(item: Item, items: Binding<[Item]>) {
        self._editedItem = State(initialValue: item)
        self._items = items
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Short Description", text: $editedItem.shortDescription)
                    .accessibilityIdentifier("editShortDescription")
                    
                
                TextField("Long Description", text: $editedItem.longDescription)
                    .accessibilityIdentifier("editLongDescription")
            }
            .padding()
            .navigationTitle("Edit Item")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red),
                
                trailing: Button("Save") {
                    if let index = items.firstIndex(where: { $0.id == editedItem.id }) {
                        items[index] = editedItem
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
