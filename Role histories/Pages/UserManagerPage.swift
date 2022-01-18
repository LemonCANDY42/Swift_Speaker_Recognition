//
//  SwiftUIView.swift
//  SwiftUIView
//
//  Created by Kenny Zhou on 2021/9/2.
//

import SwiftUI
import Foundation
import CoreData

struct UserManagerView: View {
    
    @State var UserData:UserInfo?
    
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    
    var persons: FetchedResults<User>
    
    
    
    let dateFormatter = DateFormatter()

    var body: some View {
        NavigationView {
        List {
            //将数据库中的name数据依次列出
            ForEach(persons, id: \.id) { person in
                HStack{
                Text(person.name!)
                    Text(dateFormatter.string(from: person.timestamp!))
            }
            }.onDelete(perform: delete)
            
        }
        .navigationTitle("Roles")
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let person = persons[index]
            viewContext.delete(person)
            self.UserData?.delete(id: index)
        }
       }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserManagerView()
    }
}
