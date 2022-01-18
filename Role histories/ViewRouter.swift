//
//  ViewRouter.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI

class ViewRouter: ObservableObject {
    
    @Published var currentPage: Page = .page1
    @Published var needReturn = false
    @Published var needReturnId = 0
    @Published var stopTap = false
    @Published var transcript = ""
    
}
