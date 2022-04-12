//
//  UIToolbars_iPad.swift
//  Atomic
//
//  Created by Christian Dominguez on 4/1/22.
//

import SwiftUI


// Due to the lack of a toolbar similar to what macOS offers, the same actions and buttons are shown above the main view.
extension MainWindow {
    var toolbars: some View {
        HStack(spacing: 5) {
            if moleculeVM.fileReady {
                Group {
                    //MARK: File menu
                    Menu {
                        Button {
                            moleculeVM.newFile()
                        } label: {
                            HStack{
                                Image(systemName: "doc.badge.plus")
                                Text("New")
                            }
                        }.atomicButton(fixed: true)
                        
                        
                        Button {
                            moleculeVM.openFileImporter.toggle()
                        } label: {
                            HStack{
                                Image(systemName: "doc.on.doc")
                                Text("Open")
                            }
                        }.atomicButton(fixed: true)
                        Button {
                            let file = XYZWritter.sceneToXYZ(scene: moleculeVM.renderer!.scene)
                            moleculeVM.saveFile(file)
                        } label: {
                            HStack{
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Save")
                            }
                        }.atomicButton(fixed: true)
                        Button {
                            moleculeVM.showFileMenu = false
                            moleculeVM.resetFile()
                        } label: {
                            HStack{
                                Image(systemName: "xmark")
                                Text("Close")
                            }
                        }.atomicButton(fixed: true)
                        
                        Button {
                            moleculeVM.sheetContent = AnyView(OutputFileView(fileInput: moleculeVM.fileAsString!))
                            moleculeVM.showPopover = true
                        } label: {
                            Image(systemName: "doc")
                            Text("Read")
                        }
                        .atomicButton(fixed: true)
                        .disabled(moleculeVM.fileAsString == nil)
                        
                        
                        .offset(x: 0, y: moleculeVM.showFileMenu ? 120 : 40)
                        .opacity(moleculeVM.showFileMenu ? 1 : 0)
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .rotationEffect(Angle(degrees: moleculeVM.showFileMenu ? 45 : 0))
                        Text("File")
                    }.atomicButton()
                    //MARK: View menu
                    Menu {
                        Picker("Atom style", selection: $cSettings.atomStyle) {
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
                        moleculeVM.sheetContent = AnyView(SettingsView())
                        moleculeVM.showPopover = true
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

