// Commands for macOS menu bar

import SwiftUI
import ProteinKit
import Sparkle

//MARK: Commands view
/// macOS menus on top of the screen
struct AtomicCommands: Commands {
    
    let updaterController: SPUStandardUpdaterController
    
    @State var color: Color = .white
    
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
        CommandMenu("Appearance") {
            Menu("Atom style") {
                ForEach(AtomStyle.allCases, id: \.self) { style in
                    Button {
                        commands.activeController?.renderer?.changeSelectedOrView(to: style)
                    } label: {
                        Text(style.rawValue)
                    }

                }
            }
            Button("Color") {
                guard let controller = commands.activeController else {return}
                AppearanceView(controller: controller).openNewWindow(type: .appearance, controller: controller)
            }
            Button("Hide selected") {
                commands.activeController?.renderer?.hideSelected()
            }
            Button("Show all") {
                commands.activeController?.renderer?.showAll()
            }
        }
        CommandMenu("Molecule") {
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
                guard let energy = commands.getStepsEnergy() else {return}
                AtomicLineChartView().openNewWindow(type: .energyGraph, controller: commands.activeController)
//                AtomicLineChartView(data: energy).openNewWindow(type: .energyGraph, controller: commands.activeController)
            }
            Button("Frequencies") {
            }

            Button("Summary") {

            }
        }
        CommandMenu("Camera") {
            Button("Make selection pivot") {
                if commands.activeController?.renderer?.selectedAtoms.count != 1 {
                    commands.activeController?.errorDescription = "Select one atom"
                    commands.activeController?.showErrorAlert = true
                    return
                }
                commands.activeController?.renderer?.makeSelectedPivot()
            }
            Button("Reset pivot") {
                commands.activeController?.renderer?.resetPivot()
            }
            Divider()
            Button {
                commands.seeFrom(.x)
            } label: {
                Text("X")
            }.keyboardShortcut("1")
            Button {
                commands.seeFrom(.y)
            } label: {
                Text("Y")
            }.keyboardShortcut("2")
            Button {
                commands.seeFrom(.z)
            } label: {
                Text("Z")
            }.keyboardShortcut("3")
            Button {
                commands.activeController?.renderer?.swapAxis()
            } label: {
                Text("Swap axis")
            }
            Divider()
            Button {
                commands.activeController?.renderer?.toggleFixedLightNode()
            } label: {
                Text("Toggle fixed light")
            }


        }
        CommandMenu("Input/Output") {
            Button("View file") {
                commands.viewInputFIle()
            }
        }
        CommandMenu("Debug") {
            Button("Show debug window") {
                DebugWindowView(renderer: commands.activeController!.renderer!).openNewWindow(type: .debug, controller: commands.activeController!)
            }
        }
        CommandGroup(after: .appInfo) {
                        CheckForUpdatesView(updater: updaterController.updater)
                    }
    }
}

//MARK: Commands controller

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
    
    func getStepsEnergy() -> [Double]? {
        guard let steps = activeController?.BR?.steps else {return nil}
        let energies = steps.compactMap { step in
            step.energy
        }
        return energies
    }
    
    func seeFrom(_ d: MoleculeRenderer.Direction) {
        activeController?.renderer?.rotateCamera(direction: d)
        activeController?.renderer?.cameraNode.look(at: SCNVector3(0,0,0))
    }
}
