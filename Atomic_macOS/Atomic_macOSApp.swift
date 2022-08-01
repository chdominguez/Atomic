//
//  Atomic_macOSApp.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

@main
struct Atomic_macOSApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var windowManager = MacOSWindowManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
        .commands {
            AtomicCommands()
        }
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

class WindowDelefgate: NSObject, NSWindowDelegate {
    
}
