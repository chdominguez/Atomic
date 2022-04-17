//
//  WinManager.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 9/1/22.
//

import SwiftUI

//Window manager version for iOS

class InstanceManager: ObservableObject {
    
    static let shared = InstanceManager()
    
    @Published var currentController: AtomicMainController? = nil
}


extension View {
    func openNewWindow(controller: AtomicMainController? = nil) {
        if let controller = controller {
            controller.sheetContent = AnyView(self)
            controller.showSheet = true
        } else if let controller = InstanceManager.shared.currentController {
            controller.sheetContent = AnyView(self)
            controller.showSheet = true
        }
    }
}
