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
            VStack {
                #if !os(macOS)
                toolbar
                #endif
                Spacer()
            }
            .zIndex(1)
            
            ZStack {
                if moleculeVM.loading {
                    ProgressView()
                }
                Group {
                    if moleculeVM.moleculeReady {
                        VStack {
                            SceneUI(controller: moleculeVM.controller)
                            toolbar2.padding(.horizontal).padding(.bottom, 5)
                        }
                    }
                    else {
                        VStack {
                            WelcomeMessage()
                            Image(systemName: moleculeVM.isDragginFile ? "square.and.arrow.down" : "doc")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(moleculeVM.isDragginFile ? .green : .secondary)
                        }
                       .onDrop(of: [.fileURL], delegate: moleculeVM)
                    }
                }
            }
        }.frame(minWidth: 800, minHeight: 600)
        
        .fileImporter(isPresented: $moleculeVM.openFileImporter, allowedContentTypes: FileOpener.types) { fileURL in
            moleculeVM.loading = true
            DispatchQueue.main.async {
                moleculeVM.handlePickedFile(fileURL)
                moleculeVM.loading = false
            }
            
        }
        
    }
}

extension MainWindow {
    
    private var toolbar2: some View {
        HStack {
            Text("\(moleculeVM.stepIndex + 1) / \(moleculeVM.steps.count)")
            Button {
                moleculeVM.stepIndex -= 1
            } label: {
                Image(systemName: "chevron.left")
            }
            Button {
                moleculeVM.stepIndex += 1
            } label: {
                Image(systemName: "chevron.right")
            }
            Spacer()
            Text("Energy: \(moleculeVM.steps[moleculeVM.stepIndex].energy)")
            Spacer()
            Text("Play")
            Button {
                moleculeVM.playAnimation()
            } label: {
                Image(systemName: moleculeVM.isPlaying ? "stop.fill" : "play.fill").foregroundColor(moleculeVM.isPlaying ? .red : .green)
            }

        }//.padding()
    }
    
    private var toolbar: some View {
        HStack(spacing: 5){
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
                .offset(x: 0, y: moleculeVM.showEditMenu ? 60 : 10)
                .opacity(moleculeVM.showEditMenu ? 1 : 0)
                
            }
            Spacer()
        }
        .frame(maxHeight: 20)
        .padding(10)
    }
}



