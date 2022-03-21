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
                        let file = XYZWritter.sceneToXYZ(scene: moleculeVM.renderer!.scene)
                        moleculeVM.sheetContent = AnyView(InputfileView(fileInput: file.text))
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
                        moleculeVM.sheetContent = AnyView(OutputFileView(fileInput: moleculeVM.fileAsString!))
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
            Spacer()
        }
        .frame(maxHeight: 20)
        .padding(10)
    }
}
