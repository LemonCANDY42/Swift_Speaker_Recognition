//
//  Role_historiesApp.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI

@available(iOS 15.0, *)
@main
struct Role_historiesApp: App {
    
    @StateObject var viewRouter = ViewRouter()
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
//    @State var firstLaunch = true

    var body: some Scene {
        
        WindowGroup {
//            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            MotherView()
                .environmentObject(viewRouter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }.onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
        }
    
}
