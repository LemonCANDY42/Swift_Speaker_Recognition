//
//  HistoryView.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            HappyDog()
            Button(action: {
                withAnimation {
                    viewRouter.currentPage = .page1
                }
            }) {
                BackButtonContent()
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView().environmentObject(ViewRouter())
    }
}


struct HappyDog : View {
    var body: some View {
        return Image(systemName: "pencil.and.outline")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 300, height: 600)
            .cornerRadius(10)
            .clipped()
    }
}

struct BackButtonContent : View {
    var body: some View {
        return Text("Back")
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(Color.blue)
            .cornerRadius(15)
            .padding(.top, 50)
    }
}
