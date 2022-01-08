//
//  Atomic_macOSApp.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

@main
struct Atomic_macOSApp: App {
    
    @StateObject var commandMenu = CommandMenuController.shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow().navigationTitle("Atomic")
        }
        .commands {
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
//            CommandMenu("Tools") {
//                Button("Frequencies...") {
//                    if let freqs = moleculeVM.renderer?.showingStep.frequencys {
//                        FreqsView(freqs: freqs).openNewWindow(with: "Frequencies")
//                    }
//                }.disabled(!commandMenu.hasfreq)
//            }
//            CommandMenu("Input/Output") {
//                Button("Show input file") {
//                    if let gReader = moleculeVM.gReader {
//                        InputfileView(fileInput: gReader.inputFile).openNewWindow(with: "Input file")
//                    }
//                }.disabled(moleculeVM.gReader == nil)
//                Button("Show output file") {
//                    OutputFileView(fileInput: moleculeVM.fileAsString!).openNewWindow(with: "Output file")
//                }.disabled(moleculeVM.fileAsString == nil)
//            }
        }
        Settings {
            VStack {
                Text("Settings")
            }.padding()
        }
    }
}

extension View {
    private func newWindowInternal(with title: String) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 20, y: 20, width: 680, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        window.center()
        window.isReleasedWhenClosed = false
        window.title = title
        window.makeKeyAndOrderFront(nil)
        return window
    }
    
    func openNewWindow(with title: String = "New Window") {
        self.newWindowInternal(with: title).contentView = NSHostingView(rootView: self)
    }
}
