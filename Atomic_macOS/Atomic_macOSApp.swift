//
//  Atomic_macOSApp.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

@main
struct Atomic_macOSApp: App {
    
    @StateObject var ptablecontroller = PeriodicTableViewController.shared
    @StateObject var toolscontroller = ToolsController.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow().environmentObject(ptablecontroller)
        }.commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button("Open File") {
                    print("open item")
                }
            }
        }
    }
}
