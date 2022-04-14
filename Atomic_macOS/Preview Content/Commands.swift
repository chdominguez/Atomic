//// Commands for macOS menu bar
//
//import SwiftUI
//
//struct AtomicCommands: Commands {
//
//    @ObservedObject var commandMenu = CommandMenuController.shared
//    @ObservedObject var windowManager = MacOSWindowManager.shared
//    @ObservedObject var settings = GlobalSettings.shared
//
//    var body: some Commands {
//        CommandGroup(replacing: .newItem) {
//            Button("New molecule") {
//                guard let controller = windowManager.currentController else {return}
//                controller.newFile()
//            }.keyboardShortcut("N")
//            Button("Open file") {
//                guard let controller = windowManager.currentController else {return}
//                controller.openFileImporter = true
//            }.keyboardShortcut("O")
//            Button("Close file") {
//                guard let controller = windowManager.currentController else {return}
//                controller.resetFile()
//            }
//            Button("Save") {
//                #warning("Temporary saving files of the first controller")
//                guard let controller = windowManager.currentController else {return}
//                guard let renderer = controller.renderer else {return}
//                let file = XYZWritter.sceneToXYZ(atomNodes: renderer.atomNodes)
//                controller.saveFile(file)
//            }.keyboardShortcut("S")//.disabled(commandMenu.currentScene == nil)
//            Divider()
//            Button("New window") {
//                MainWindow().openNewWindow(with: "Atomic", multiple: true)
//            }
//        }
//        CommandMenu("Molecule") {
//            Picker("Atom style", selection: $settings.atomStyle) {
//                ForEach(AtomStyle.allCases, id: \.self) { Text($0.rawValue) }
//            }
//            Button("Periodic table") {
//                ToolsController.shared.selectedTool = .addAtom
//                guard let controller = windowManager.currentController else {return}
//                PTable().openNewWindow(with: "Periodic Table", multiple: false, controller: controller)
//            }
//            Button("Select") {
//                ToolsController.shared.selectedTool = .selectAtom
//            }
//            Button("Erase") {
//                ToolsController.shared.selectedTool = .removeAtom
//            }
//            Button("Bond selected") {
//                windowManager.currentController?.renderer?.bondSelectedAtoms()
//            }.keyboardShortcut("B")
//            Button("Remove selected") {
//                windowManager.currentController?.renderer?.eraseSelectedAtoms()
//            }.keyboardShortcut("R")
//        }
//        CommandMenu("Tools") {
//            #warning("TODO: Implement tools for macOS and iOS")
//            Button("Energy") {
//
//            }
//            Button("Frequencies") {
//            }
//
//            Button("Summary") {
//
//            }
//        }
//        CommandMenu("Input/Output") {
//            Button("Show input file") {
//                if let BR = windowManager.currentController!.BR {
//                    let fileAsString = BR.openedFile.joined(separator: "\n")
//                    InputfileView(fileInput: fileAsString).openNewWindow(with: "Input file", multiple: false, controller: windowManager.currentController)
//                }
//            }//.disabled(moleculeVM.gReader == nil)
//            Button("Show output file") {
//                //OutputFileView(fileInput: moleculeVM.fileAsString!).openNewWindow(with: "Output file")
//            }//.disabled(moleculeVM.fileAsString == nil)
//        }
//    }
//}
