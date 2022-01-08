//
//  UIToolbars_iPad.swift
//  Atomic
//
//  Created by Christian Dominguez on 4/1/22.
//

import SwiftUI

extension MainWindow {
    var toolbars: some View {
        HStack(spacing: 5) {
            ZStack {
                Button {
                    withAnimation {
                        moleculeVM.showFileMenu.toggle()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .rotationEffect(Angle(degrees: moleculeVM.showFileMenu ? 45 : 0))
                    Text("File")
                }
                .zIndex(1)
                .atomicButton()
                
                VStack {
                    Button {
                        moleculeVM.newFile()
                    } label: {
                        HStack{
                            Image(systemName: "doc.badge.plus")
                            Text("New")
                        }
                    }.atomicButton()
                    
                    
                    Button {
                        moleculeVM.openFileImporter.toggle()
                    } label: {
                        HStack{
                            Image(systemName: "doc.on.doc")
                            Text("Open")
                        }
                    }.atomicButton()
                    Button {
                        let file = GJFWritter.sceneToGJF(scene: moleculeVM.renderer!.scene)
                        moleculeVM.popoverContent = AnyView(InputfileView(fileInput: file))
                        moleculeVM.showPopover = true
                    } label: {
                        HStack{
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Save")
                        }
                    }.atomicButton()
                    Button {
                        moleculeVM.showFileMenu = false
                        moleculeVM.resetFile()
                    } label: {
                        HStack{
                            Image(systemName: "xmark")
                            Text("Close")
                        }
                    }.atomicButton()
                    
                    Button {
                        moleculeVM.popoverContent = AnyView(OutputFileView(fileInput: moleculeVM.fileAsString!))
                        moleculeVM.showPopover = true
                    } label: {
                        Image(systemName: "doc")
                        Text("Show output")
                    }
                    .atomicButton()
                    .disabled(moleculeVM.fileAsString == nil)
                    
                }
                .offset(x: 0, y: moleculeVM.showFileMenu ? 100 : 40)
                .opacity(moleculeVM.showFileMenu ? 1 : 0)
                
            }
            ZStack {
                Button {
                    withAnimation {
                        moleculeVM.showEditMenu.toggle()
                    }
                } label: {
                    Image(systemName: "paintbrush.pointed")
                        .rotationEffect(Angle(degrees: moleculeVM.showEditMenu ? 45 : 0))
                    Text("Edit")
                }
                .zIndex(1)
                .atomicButton()
                
                VStack {
                    Button {
                        ToolsController.shared.selected2Tool = .addAtom
                        moleculeVM.popoverContent = AnyView(PTable())
                        moleculeVM.showPopover = true
                    } label: {
                            Text("Periodic table")
                    }.atomicButton()
                    Button {
                        moleculeVM.renderer?.eraseSelectedAtoms()
                    } label: {
                        HStack{
                            Image(systemName: "trash")
                            Text("Erase")
                        }
                    }.atomicButton()
                    Button {
                        moleculeVM.renderer?.bondSelectedAtoms()
                    } label: {
                        HStack{
                            Image(systemName: "link")
                            Text("Bond")
                        }
                    }.atomicButton()
                }
                .offset(x: 0, y: moleculeVM.showEditMenu ? 60 : 10)
                .opacity(moleculeVM.showEditMenu ? 1 : 0)
                
            }
            Spacer()
        }
        .frame(maxHeight: 20)
        .padding(10)
    }
}
