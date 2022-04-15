//
//  UIToolbars_iPad.swift
//  Atomic
//
//  Created by Christian Dominguez on 4/1/22.
//

import SwiftUI


// Due to the lack of a toolbar similar to what macOS offers, the same actions and buttons are shown above the main view.
extension MainWindow {
    var iOSToolBarReplacement: some View {
        HStack(spacing: 5) {
            if controller.fileReady {
                Group {
                    //MARK: File menu
                    Menu {
                        Button {
                            controller.newFile()
                        } label: {
                            HStack{
                                Image(systemName: "doc.badge.plus")
                                Text("New")
                            }
                        }.atomicButton(fixed: true)
                        
                        
                        Button {
                            controller.openFileImporter.toggle()
                        } label: {
                            HStack{
                                Image(systemName: "doc.on.doc")
                                Text("Open")
                            }
                        }.atomicButton(fixed: true)
                        Button {
                            guard let renderer = controller.renderer else {return}
                            let file = XYZWritter.sceneToXYZ(atomNodes: renderer.atomNodes)
                            controller.saveFile(file)
                        } label: {
                            HStack{
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Save")
                            }
                        }.atomicButton(fixed: true)
                        Button {
                            controller.showFileMenu = false
                            controller.resetFile()
                        } label: {
                            HStack{
                                Image(systemName: "xmark")
                                Text("Close")
                            }
                        }.atomicButton(fixed: true)
                        
                        Button {
                            controller.sheetContent = AnyView(OutputFileView(fileInput: controller.fileAsString!))
                            controller.showSheet = true
                        } label: {
                            Image(systemName: "doc")
                            Text("Read")
                        }
                        .atomicButton(fixed: true)
                        .disabled(controller.fileAsString == nil)
                        
                        
                        .offset(x: 0, y: controller.showFileMenu ? 120 : 40)
                        .opacity(controller.showFileMenu ? 1 : 0)
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .rotationEffect(Angle(degrees: controller.showFileMenu ? 45 : 0))
                        Text("File")
                    }.atomicButton()
                    //MARK: View menu
                    Menu {
                        Picker("Atom style", selection: $settings.atomStyle) {
                            ForEach(AtomStyle.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                    } label: {
                        Image(systemName: "paintpalette")
                        Text("View")
                    }.atomicButton()
                    //MARK: Tools menu
                    Menu {
                        Button("Energy") {
                        }
                        Button("Vibrations") {
                            
                        }
                        Button("Summary") {
                            
                        }
                    } label: {
                        Image(systemName: "hammer")
                        Text("Tools")
                    }
                    .atomicButton()
                    //MARK: Settings
                    Button {
                        controller.sheetContent = AnyView(SettingsView())
                        controller.showSheet = true
                    } label: {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .atomicButton()
                }
            }
            Spacer()
        }
        .foregroundColor(.primary)
        .frame(maxHeight: 20)
        .padding(10)
    }
}

