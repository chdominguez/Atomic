//
//  Commands.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 8/1/22.
//

import SwiftUI


struct AtomicCommands: Commands {
    
    @ObservedObject var commandMenu = CommandMenuController.shared
    @ObservedObject var windowManager = WindowManager.shared
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New molecule") {
                guard let controller = windowManager.currentController else {return}
                controller.newFile()
            }.keyboardShortcut("N")
            Button("Open file") {
                guard let controller = windowManager.currentController else {return}
                controller.openFileImporter = true
            }.keyboardShortcut("O")
            Button("Close file") {
                guard let controller = windowManager.currentController else {return}
                controller.resetFile()
            }
            Button("Save") {
                let file = GJFWritter.sceneToGJF(scene: commandMenu.currentScene!)
                InputfileView(fileInput: file).openNewWindow(with: "New file")
            }.keyboardShortcut("S").disabled(commandMenu.currentScene == nil)
            Divider()
            Button("New window") {
                MainWindow().openNewWindow(with: "Atomic", and: .multiple)
            }
        }
        CommandMenu("Molecule") {
            Button("Periodic table") {
                ToolsController.shared.selected2Tool = .addAtom
                PTable().openNewWindow(with: "Periodic Table", and: .ptable)
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
        CommandMenu("Tools") {
            Button("Frequencies...") {
                if let freqs = windowManager.currentController!.renderer?.showingStep.frequencys {
                    FreqsView(freqs: freqs).openNewWindow(with: "Frequencies", and: .freqs, controller: windowManager.currentController!)
                }
            }.disabled(!commandMenu.hasfreq)
        }
        CommandMenu("Input/Output") {
            Button("Show input file") {
                if let gReader = windowManager.currentController!.gReader {
                    
                    InputfileView(fileInput: gReader.inputFile).openNewWindow(with: "Input file", and: .inputfile)
                } else {
                    print("No greader")
                }
            }//.disabled(moleculeVM.gReader == nil)
            Button("Show output file") {
                //OutputFileView(fileInput: moleculeVM.fileAsString!).openNewWindow(with: "Output file")
            }//.disabled(moleculeVM.fileAsString == nil)
        }
    }
}
