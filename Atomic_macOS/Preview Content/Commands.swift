// Commands for macOS menu bar

import SwiftUI

/// macOS menus on top of the screen
struct AtomicCommands: Commands {
    
    @ObservedObject var commands = AtomicComandsController()

    #warning("TODO: Disable buttons when required")
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            
            Button("New molecule") {
                commands.newMolecule()
            }
            .keyboardShortcut("N")
            
            Button("Open file") {
                commands.openFile()
            }
            .keyboardShortcut("O")
            
            Button("Close file") {
                commands.closeFile()
            }
            
            Button("Save") {
                commands.saveFile()
            }.keyboardShortcut("S")
            
            Divider()
            
            Button("New window") {
                commands.newWindow()
            }
        }
        CommandMenu("Molecule") {
            Picker("Atom style", selection: $commands.settings.atomStyle) {
                ForEach(AtomStyle.allCases, id: \.self) { Text($0.rawValue) }
            }
            Button("Periodic table") {
                PTable().openNewWindow(type: .ptable)
            }
            Button("Select") {
                commands.activeController?.renderer?.selectedTool = .selectAtom
            }
            Button("Erase") {
                commands.activeController?.renderer?.selectedTool = .removeAtom
            }
            Button("Bond selected") {
                commands.activeController?.renderer?.bondSelectedAtoms()
            }.keyboardShortcut("B")
        }
        CommandMenu("Tools") {
            #warning("TODO: Implement views for for macOS and iOS")
            Button("Energy") {

            }
            Button("Frequencies") {
            }

            Button("Summary") {

            }
        }
        CommandMenu("Input/Output") {
            Button("View file") {
                commands.viewInputFIle()
            }
        }
    }
}

class AtomicComandsController: ObservableObject {
    
    @Published var wManager = MacOSWindowManager.shared
    @Published var settings = GlobalSettings.shared
    
    /// The active AtomicMainController. NOT to be used to define views. As its not a @Published var
    var activeController: AtomicMainController? { wManager.activeController }
    
    /// Erases the active controller and creates a new one on the active window
    func newMolecule() {
        activeController?.newFile()
    }
    
    /// Opens the file picker on the active controller
    func openFile() {
        activeController?.openFileImporter = true
    }
    
    /// Erases the active controller and presents the Welcome window
    func closeFile() {
        activeController?.resetFile()
    }
    
    /// Generates a new file with the active controller scene.
    func saveFile() {
        guard let atomNodes = activeController?.renderer?.atomNodes else {return}
        let file = XYZWritter.sceneToXYZ(atomNodes: atomNodes)
        activeController?.saveFile(file)
    }
    
    /// Opens a new Main window
    func newWindow() {
        MainWindow().openNewWindow(type: .mainWindow)
    }
    
    /// Opens a view with the opened file
    func viewInputFIle() {
        guard let file = activeController?.fileAsString else {return}
        InputfileView(fileInput: file).openNewWindow(type: .openedFile, controller: activeController)
    }
}
