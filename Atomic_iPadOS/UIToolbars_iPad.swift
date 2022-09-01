//
//  UIToolbars_iPad.swift
//  Atomic
//
//  Created by Christian Dominguez on 4/1/22.
//

import SwiftUI
import ProteinKit

// Due to the lack of a toolbar similar to what macOS offers, the same actions and buttons are shown above the main view.
extension MainWindow {
    var iOSToolBarReplacement: some View {
        HStack(spacing: 5) {
            fileMenu
            viewMenu
            toolsMenu
            cameraMenu
            settingsMenu
            Spacer()
        }
        .padding(.horizontal)
        .foregroundColor(.primary)
    }
    
    private var fileMenu: some View {
        //MARK: File menu
        Menu {
            // New file
            Button {
                controller.newFile()
            } label: {
                HStack{
                    Image(systemName: "doc.badge.plus")
                    Text("New")
                }
            }
            
            // Open file
            Button {
                controller.openFileImporter.toggle()
            } label: {
                HStack{
                    Image(systemName: "doc.on.doc")
                    Text("Open")
                }
            }
            
            // Save file
            Button {
                guard let renderer = controller.renderer else {return}
                let file = XYZWritter.sceneToXYZ(atomNodes: renderer.atomNodes)
                controller.saveFile(file)
            } label: {
                HStack{
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Save")
                }
            }
            
            // Reset file
            Button {
                controller.resetFile()
            } label: {
                HStack{
                    Image(systemName: "xmark")
                    Text("Close")
                }
            }.disabled(!controller.fileReady)
            
            // Read opened file
            Button {
                controller.sheetContent = AnyView(OutputFileView(fileInput: controller.fileAsString!))
                controller.showSheet = true
            } label: {
                HStack {
                    Image(systemName: "doc")
                    Text("Read output")
                }
            }.disabled(controller.fileAsString == nil)
            
        } label: {
            // Label of the menu
            Button {} label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("File")
                }
            }.toolbarButton()
        }
    }
    
    private var viewMenu: some View {
        //MARK: View menu
        Menu {
            Picker("Atom style", selection: $settings.atomStyle) {
                ForEach(AtomStyle.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            Button {
                AppearanceView(controller: controller).openNewWindow(controller: controller)
            } label: {
                Text("Appearance")
            }

        } label: {
            Button {} label: {
                HStack {
                    Image(systemName: "paintpalette")
                    Text("View")
                }
            }.toolbarButton()
        }
    }
    
    private var toolsMenu: some View {
        //MARK: Tools menu
        Menu {
            // Show energy plot
            Button("Energy") {
                guard let steps = controller.BR?.steps else {return}
                let energies = steps.compactMap { step in
                    step.energy
                }
                AtomicLineChartView(data: energies).openNewWindow(controller: controller)
            }
            
            // Show freq results
            Button("Vibrations") {
                
            }
            
            // Energy, optimization... summary
            Button("Summary") {
                
            }
        } label: {
            Button {} label: {
                HStack {
                    Image(systemName: "hammer")
                    Text("Tools")
                }
            }        .toolbarButton()
        }
    }
    
    private var cameraMenu: some View {
        Menu {
        //MARK: Camera
        Button("Make selection pivot") {
            if controller.renderer?.selectedAtoms.count != 1 {
                controller.errorDescription = "Select one atom"
                controller.showErrorAlert = true
                return
            }
            controller.renderer?.makeSelectedPivot()
        }
        Button("Reset pivot") {
            controller.renderer?.resetPivot()
        }
        Divider()
        Button {
            controller.renderer?.cameraNode.position = SCNVector3(8, 0, 0)
            controller.renderer?.cameraNode.look(at: SCNVector3(0,0,0))
        } label: {
            Text("X")
        }
        Button {
            controller.renderer?.cameraNode.position = SCNVector3(0, 8, 0)
            controller.renderer?.cameraNode.look(at: SCNVector3(0,0,0))
        } label: {
            Text("Y")
        }
        Button {
            controller.renderer?.cameraNode.position = SCNVector3(0, 0, 8)
            controller.renderer?.cameraNode.look(at: SCNVector3(0,0,0))
        } label: {
            Text("Z")
        }
        Divider()
            Button {
                controller.renderer?.toggleFixedLightNode()
            } label: {
                Text("Fix/unfix light")
            }

            
        } label: {
            Button {} label: {
                HStack {
                    Image(systemName: "video")
                    Text("Camera")
                }
            }        .toolbarButton()
        }
        
    }
    
    private var settingsMenu: some View {
        //MARK: Settings
        Button {
            SettingsView().openNewWindow(controller: controller)
        } label: {
            HStack {
                Image(systemName: "gear")
                Text("Settings")
            }
        }.toolbarButton()
    }
}

