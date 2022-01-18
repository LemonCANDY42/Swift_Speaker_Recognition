//
//  MotherView.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI

@available(iOS 15.0, *)
struct MotherView: View {
    
//    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewRouter: ViewRouter
//    let persistenceController : PersistenceController.shared!
    
    var body: some View {
        switch viewRouter.currentPage {
        case .page1:
            BaseView()
//                .transition(.move(edge: .top))
//                .transition(.slide)
        case .page2:
            HistoryView()
                .transition(.move(edge: .bottom))
//                .transition(.scale)
        case .page3:
            AudioRecorderView(audioRecorder: AudioRecorder())
                .transition(.move(edge: .bottom))
        }
    }
}

@available(iOS 15.0, *)
struct MotherView_Previews: PreviewProvider {
    static var previews: some View {
        MotherView()
            .environmentObject(ViewRouter())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
