//
//  AtomicApp.swift
//  Atomic
//
//  Created by Christian Dominguez on 7/9/21.
//

import SwiftUI

@main
struct AtomicApp: App {
    
    @StateObject var ptablecontroller = PeriodicTableViewController.shared
    @StateObject var toolscontroller = ToolsController.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow().environmentObject(ptablecontroller)
                .onOpenURL { url in
                    print("*** url")
                }
        }
    }
}

