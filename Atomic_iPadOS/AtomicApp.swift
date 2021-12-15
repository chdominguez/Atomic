//
//  AtomicApp.swift
//  Atomic
//
//  Created by Christian Dominguez on 7/9/21.
//

import SwiftUI

@main
struct AtomicApp: App {
    
    @StateObject var moleculeVM = MoleculeViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainWindow(moleculeVM: moleculeVM)
        }
    }
}

