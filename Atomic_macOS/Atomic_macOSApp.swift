//
//  Atomic_macOSApp.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

@main
struct Atomic_macOSApp: App {
    
    @StateObject var commandMenu = CommandMenuController.shared
    @StateObject var windowManager = WindowManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
        .commands {
            AtomicCommands()
        }
        Settings {
            VStack {
                Text("Settings")
            }.padding()
        }
    }
}
