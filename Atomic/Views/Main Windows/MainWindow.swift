//
//  MainWindow.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/9/21.
//

import SwiftUI
import Combine

struct MainWindow: View {
    
    @StateObject var mainWindowVM = StartingWindow()
    @StateObject var moleculeVM = MoleculeViewModel()
    @State var dragOver = false
    
    var body: some View {
        ZStack {
            VStack {
                toolbar
                Spacer()
            }
            .zIndex(1)
            ZStack {
                if moleculeVM.loading {
                    ProgressView()
                    Color.gray.opacity(0.25)
                }
                Group {
                    if moleculeVM.moleculeReady {
                        MoleculeView(moleculeVM: moleculeVM)
                    }
                    else {
                        VStack {
                            //WelcomeMessage()
                            Image(systemName: "doc")//.font(.custom(size: 40))
                                //.frame(width: 100, height: 100)
                                .foregroundColor(dragOver ? .green : .secondary)
                        }
                        
                        .onDrop(of: FileOpener.types, isTargeted: $dragOver) { providers -> Bool in
                            moleculeVM.handleDrop(providers)
                            return true
                        }
                        
                    }
                }
            }
        }
        .fileImporter(isPresented: $mainWindowVM.openFileImporter, allowedContentTypes: FileOpener.types) { fileURL in
            moleculeVM.loading = true
            DispatchQueue.main.async {
                moleculeVM.handlePickedFile(fileURL)
                moleculeVM.loading = false
            }
            
        }
        
    }
}

extension MainWindow {
    
    private var toolbar: some View {
        HStack(spacing: 5){
            ZStack {
                Button {
                    withAnimation {
                        mainWindowVM.showFile.toggle()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .rotationEffect(Angle(degrees: mainWindowVM.showFile ? 45 : 0))
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
                        mainWindowVM.openFileImporter.toggle()
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
                    Button {
                        mainWindowVM.showFile = false
                        moleculeVM.resetFile()
                    } label: {
                        HStack{
                            Image(systemName: "xmark")
                            Text("Close")
                        }
                    }.atomicButton()
                }
                .offset(x: 0, y: mainWindowVM.showFile ? 100 : 40)
                .opacity(mainWindowVM.showFile ? 1 : 0)
                
            }
            ZStack {
                Button {
                    withAnimation {
                        mainWindowVM.showEdit.toggle()
                    }
                } label: {
                    Image(systemName: "paintbrush.pointed")
                        .rotationEffect(Angle(degrees: mainWindowVM.showEdit ? 45 : 0))
                    Text("Edit")
                }
                .zIndex(1)
                .atomicButton()
                
                VStack {
                    Button {
                        moleculeVM.controller.eraseSelectedAtoms()
                    } label: {
                        HStack{
                            Image(systemName: "trash")
                            Text("Erase")
                        }
                    }.atomicButton()
                    Button {
                        moleculeVM.controller.bondSelectedAtoms()
                    } label: {
                        HStack{
                            Image(systemName: "link")
                            Text("Bond")
                        }
                    }.atomicButton()
                }
                .offset(x: 0, y: mainWindowVM.showEdit ? 60 : 10)
                .opacity(mainWindowVM.showEdit ? 1 : 0)
                
            }
            Spacer()
        }
        .frame(maxHeight: 20)
        .padding(10)
    }
}


