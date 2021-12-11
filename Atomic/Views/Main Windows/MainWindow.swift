//
//  MainWindow.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/9/21.
//

import SwiftUI
import Combine

struct MainWindow: View {
    
    @ObservedObject var controller = RendererController()
    
    @State var showFile = false
    
    @State var showEdit = false
    
    @ObservedObject var toolsController: ToolsController = ToolsController.shared
    
    @State var periodicVisible = false
    
    @State var periodicBarVisible = false
    
    var body: some View {
        ZStack {
            VStack {
                toolbar1
                Spacer()
            }.zIndex(1)
            //editToolbar.background(Color.gray.opacity(0.5))
            //.opacity(toolsController.selected1Tool == .edit ? 1 : 0)
            MoleculeView()
        }
    }
}

extension MainWindow {
    
    private var demoMolecule: some View {
        SceneUI(controller: controller)
    }
    
    private var editToolbar: some View {
        HStack {
            Button {
                periodicVisible.toggle()
            } label: {
                Text("Periodic table")
            }
            .popover(isPresented: $periodicVisible, content: {
                PTable(visible: $periodicVisible)
                    .frame(width: 800)
            })
            
            Button {
                toolsController.selected2Tool = .selectAtom
            } label: {
                Text("Select")
            }
            
            Button {
                
            } label: {
                HStack{
                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill").rotationEffect(Angle(degrees: 90))
                    Text("Bond")
                }
            }
            
            Spacer()
        }
    }
    
    private var toolbar1: some View {
        HStack(spacing: 5){
            ZStack {
                Button {
                    withAnimation {
                        showFile.toggle()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .rotationEffect(Angle(degrees: showFile ? 45 : 0))
                    Text("File")
                }
                .zIndex(1)
                .atomicButton()
                
                VStack {
                    Button {
                        print("New file")
                    } label: {
                        HStack{
                            Image(systemName: "doc.badge.plus")
                            Text("New")
                        }
                    }.atomicButton()
                    
                    
                    Button {
                        print("Open file")
                    } label: {
                        HStack{
                            Image(systemName: "doc.on.doc")
                            Text("Open")
                        }
                    }.atomicButton()
                    Button {
                        print("Save file")
                    } label: {
                        HStack{
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Save")
                        }
                    }.atomicButton()
                }
                .offset(x: 0, y: showFile ? 80 : 40).opacity(showFile ? 1 : 0)
                    
            }
            ZStack {
                Button {
                    withAnimation {
                        showEdit.toggle()
                    }
                } label: {
                    Image(systemName: "paintbrush.pointed")
                        .rotationEffect(Angle(degrees: showEdit ? 45 : 0))
                    Text("Edit")
                }
                .zIndex(1)
                .atomicButton()
                
                VStack {
                    Button {
                        controller.eraseSelectedAtoms()
                    } label: {
                        HStack{
                            Image(systemName: "trash")
                            Text("Erase")
                        }
                    }.atomicButton()
                    Button {
                        controller.bondSelectedAtoms()
                    } label: {
                        HStack{
                            Image(systemName: "link")
                            Text("Bond")
                        }
                    }.atomicButton()
                }
                .offset(x: 0, y: showEdit ? 60 : 10).opacity(showEdit ? 1 : 0)
                    
            }
            Spacer()
        }
        .frame(maxHeight: 20)
        .padding(10)
    }
}



