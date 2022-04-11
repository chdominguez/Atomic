// Commands for macOS menu bar

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
                let file = XYZWritter.sceneToXYZ(scene: commandMenu.currentScene!)
                windowManager.currentController?.saveFile(file)
//                InputfileView(fileInput: file).openNewWindow(with: "New file")
            }.keyboardShortcut("S").disabled(commandMenu.currentScene == nil)
            Divider()
            Button("New window") {
                MainWindow().openNewWindow(with: "Atomic", and: .multiple)
            }
        }
        CommandMenu("Molecule") {
            Button("Periodic table") {
                ToolsController.shared.selected2Tool = .addAtom
                guard let controller = windowManager.currentController else {return}
                PTable().openNewWindow(with: "Periodic Table", and: .ptable, controller: controller)
            }
            Button("Select") {
                ToolsController.shared.selected2Tool = .selectAtom
            }
            Button("Erase") {
                ToolsController.shared.selected2Tool = .removeAtom
            }
            Button("Bond selected") {
                windowManager.currentController?.renderer?.bondSelectedAtoms()
            }.keyboardShortcut("B")
            Button("Remove selected") {
                windowManager.currentController?.renderer?.eraseSelectedAtoms()
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
                if let BR = windowManager.currentController!.BR {
                    let fileAsString = BR.openedFile.joined(separator: "\n")
                    InputfileView(fileInput: fileAsString).openNewWindow(with: "Input file", and: .inputfile)
                }
            }//.disabled(moleculeVM.gReader == nil)
            Button("Show output file") {
                //OutputFileView(fileInput: moleculeVM.fileAsString!).openNewWindow(with: "Output file")
            }//.disabled(moleculeVM.fileAsString == nil)
        }
    }
}
