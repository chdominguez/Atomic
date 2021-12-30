//
//  MainWindow.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/9/21.
//

import SwiftUI
import Combine

struct MainWindow: View {
    
    @ObservedObject var moleculeVM: MoleculeViewModel
    
    var body: some View {
        ZStack {
            if moleculeVM.fileReady {
                Molecule3DView(controller: moleculeVM.renderer!)
            }
            else {
                VStack {
                    WelcomeMessage()
                    ZStack {
                        if moleculeVM.loading {
                            VStack {
                                ProgressView()
                                Text("Reading file")
                            }
                        }
                        else {
                            VStack {
                                Image(systemName: moleculeVM.isDragginFile ? "square.and.arrow.down" : "doc")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(moleculeVM.isDragginFile ? .green : .secondary)
                            }
                            if moleculeVM.isDragginFile {
                                Rectangle()
                                    .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10], dashPhase: moleculeVM.phase))
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.green)
                                    .onAppear {
                                        withAnimation(.linear.repeatForever(autoreverses: false)) {
                                            moleculeVM.phase -= 20
                                        }
                                    }
                            }
                        }
                        
                    }
                    .frame(width: 120, height: 120)
                    .padding()
                }
                
            }
            #if os(iOS)
            VStack {
                toolbar
                Spacer()
            }
            #endif
        }
        .alert(isPresented: $moleculeVM.showErrorFileAlert) {
            Alert(title: Text("File error"), message: Text(moleculeVM.errorDescription), dismissButton: .default(Text("Ok")))
        }
        .onDrop(of: [.fileURL], delegate: moleculeVM)
        .frame(minWidth: 800, minHeight: 600)
        .fileImporter(isPresented: $moleculeVM.openFileImporter, allowedContentTypes: FileOpener.types) { fileURL in
            moleculeVM.handlePickedFile(fileURL)
        }
    }
}

extension MainWindow {
    private var toolbar: some View {
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
                        print("New file")
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
                        print("Save file")
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
