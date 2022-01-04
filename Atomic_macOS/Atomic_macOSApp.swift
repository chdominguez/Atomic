//
//  Atomic_macOSApp.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

@main
struct Atomic_macOSApp: App {
    
    @StateObject var moleculeVM = MoleculeViewModel.shared
    @StateObject var commandMenu = CommandMenuController.shared
    
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
                Button("Save...") {
                    let file = GJFWritter.SceneToGJF(scene: commandMenu.currentScene!)
                    print(file)
                }.keyboardShortcut("S").disabled(commandMenu.currentScene == nil)
                Button("Show input file...") {
                    if let gReader = moleculeVM.gReader {
                        InputfileView(fileInput: gReader.inputFile).openNewWindow(with: "Input file")
                    }
                }.disabled(moleculeVM.gReader == nil)
                Button("Show output file...") {
                    OutputFileView(fileInput: moleculeVM.fileAsString!).openNewWindow(with: "Output file")
                }.disabled(moleculeVM.fileAsString == nil)
            }
            CommandMenu("Molecule") {
                    Button("Bond selected") {
                        moleculeVM.renderer?.bondSelectedAtoms()
                    }.keyboardShortcut("B")
                    Button("Remove selected") {
                        moleculeVM.renderer?.eraseSelectedAtoms()
                    }.keyboardShortcut("R")
            }
            CommandMenu("Tools") {
                Button("Frequencies...") {
                    if let freqs = moleculeVM.renderer?.showingStep.frequencys {
                        FreqsView(freqs: freqs).openNewWindow(with: "Frequencies")
                    }
                }.disabled(!commandMenu.hasfreq)
            }
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
