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
            
    var body: some View {
        ZStack {
            VStack {
                toolbar
                Spacer()
            }
            .zIndex(1)
            if mainWindowVM.userDidOpenAFile {
                MoleculeView(moleculeVM: moleculeVM)
            }
            else {
                WelcomeMessage()
            }
            
        }
        .fileImporter(isPresented: $mainWindowVM.openFileImporter, allowedContentTypes: FileOpener.types) { fileURL in
            moleculeVM.getFile(fileURL)
            mainWindowVM.userDidOpenAFile = true
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
                }
                .offset(x: 0, y: mainWindowVM.showFile ? 80 : 40)
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
                        //moleculeVM.controller.eraseSelectedAtoms()
                    } label: {
                        HStack{
                            Image(systemName: "trash")
                            Text("Erase")
                        }
                    }.atomicButton()
                    Button {
                        //moleculeVM.controller.bondSelectedAtoms()
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



