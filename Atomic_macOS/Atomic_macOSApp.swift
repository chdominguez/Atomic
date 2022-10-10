//
//  Atomic_macOSApp.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI
import Sparkle

@main
struct Atomic_macOSApp: App {
    
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        // This is where you can also pass an updater delegate if you need one
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var windowManager = MacOSWindowManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
        .commands {
            AtomicCommands(updaterController: updaterController)
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
