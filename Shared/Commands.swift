//
//  Commands.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 8/1/22.
//

import SwiftUI


struct AtomicCommands: Commands {
    
    @ObservedObject var commandMenu = CommandMenuController.shared
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New molecule") {
                //moleculeVM.newFile()
            }.keyboardShortcut("N")
            Button("Open file") {
                //moleculeVM.openFileImporter = true
            }.keyboardShortcut("O")
            Button("Close file") {
                //moleculeVM.resetFile()
            }.keyboardShortcut("W")
            Button("Save") {
                let file = GJFWritter.sceneToGJF(scene: commandMenu.currentScene!)
                InputfileView(fileInput: file).openNewWindow(with: "New file")
            }.keyboardShortcut("S").disabled(commandMenu.currentScene == nil)
        }
        CommandMenu("Molecule") {
            Button("Periodic table") {
                ToolsController.shared.selected2Tool = .addAtom
                PTable().openNewWindow(with: "Periodic Table")
            }
            Button("Select") {
                ToolsController.shared.selected2Tool = .selectAtom
            }
            Button("Erase") {
                ToolsController.shared.selected2Tool = .removeAtom
            }
            Button("Bond selected") {
                //moleculeVM.renderer?.bondSelectedAtoms()
            }.keyboardShortcut("B")
            Button("Remove selected") {
                //moleculeVM.renderer?.eraseSelectedAtoms()
            }.keyboardShortcut("R")
        }
//        CommandMenu("Tools") {
//            Button("Frequencies...") {
//                if let freqs = moleculeVM.renderer?.showingStep.frequencys {
//                    FreqsView(freqs: freqs).openNewWindow(with: "Frequencies")
//                }
//            }.disabled(!commandMenu.hasfreq)
//        }
//        CommandMenu("Input/Output") {
//            Button("Show input file") {
//                if let gReader = moleculeVM.gReader {
//                    InputfileView(fileInput: gReader.inputFile).openNewWindow(with: "Input file")
//                }
//            }//.disabled(moleculeVM.gReader == nil)
//            Button("Show output file") {
//                //OutputFileView(fileInput: moleculeVM.fileAsString!).openNewWindow(with: "Output file")
//            }//.disabled(moleculeVM.fileAsString == nil)
//        }
    }
}
