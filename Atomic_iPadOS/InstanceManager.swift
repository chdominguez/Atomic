//
//  WinManager.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 9/1/22.
//

import SwiftUI

//Window manager version for iOS

class WindowManager: ObservableObject {
    
    static let shared = WindowManager()
    
    @Published var currentController: MoleculeViewModel? = nil
}


extension View {
    func WindowInternaliOS(controller: MoleculeViewModel? = nil) {
        controller?.sheetContent = AnyView(self)
        controller?.showPopover = true
    }
}
