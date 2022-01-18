 //
//  UserDataModel.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import Foundation
import SwiftUI
import CoreData

struct ManageUserData: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var items: FetchedResults<User>

    var body: some View {
        List {
            ForEach(items) { User in
                Text("User at \(User.timestamp!, formatter: itemFormatter), \(User.name!),\(User.url!)")
            }
            .onDelete(perform: deleteItems)
        }
//        .toolbar {
            //#if os(iOS)
//            EditButton()
            //#endif

            Button(action: {addItem(userName:"1",url: URL(string: "UserData")!)}) {
                Label("Add User", systemImage: "plus")
//            }
        }
    }

    private func addItem(userName: String, url: URL) {
        withAnimation {
            let newItem = User(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = userName
            newItem.url = url
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ManageUserData().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
