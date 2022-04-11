//
//  AtomicApp.swift
//  Atomic
//
//  Created by Christian Dominguez on 7/9/21.
//

import SwiftUI

@main
struct AtomicApp: App {
    
    @StateObject var windowManager = WindowManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
    }
}

