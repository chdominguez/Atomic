//
//  Atomic_macOSApp.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

@main
struct Atomic_macOSApp: App {
    
    @StateObject var moleculeVM = MoleculeViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainWindow(moleculeVM: moleculeVM)
        }.commands {
            CommandGroup(replacing: .newItem) {
                Button("New molecule") {
                    // implement new file
                }.keyboardShortcut("N")
                Button("Open file") {
                    moleculeVM.openFileImporter = true
                }.keyboardShortcut("O")
                Button("Close file") {
                    moleculeVM.resetFile()
                }.keyboardShortcut("W")
            }
            CommandMenu("Tools") {
                    Button("Bond selected") {
                        moleculeVM.renderer?.bondSelectedAtoms()
                    }.keyboardShortcut("B")
                    Button("Remove selected") {
                        moleculeVM.renderer?.eraseSelectedAtoms()
                    }.keyboardShortcut("R")
            }
        }
    }
}
