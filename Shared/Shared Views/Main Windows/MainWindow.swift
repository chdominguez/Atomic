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
                VStack(spacing: 50) {
                    WelcomeMessage()
                    ZStack {
                        if moleculeVM.loading {
                            VStack {
                                ProgressView()
                                Text("Reading file")
                            }
                        }
                        else {
                            HStack(spacing: 100) {
                                VStack {
                                    Image(systemName: "plus").resizable().scaledToFit().frame(width: 100, height: 100).foregroundColor(.secondary)
                                    Text("New molecule")
                                }.onTapGesture {
                                    moleculeVM.newFile()
                                }
                                ZStack {
                                    VStack {
                                        Image(systemName: moleculeVM.isDragginFile ? "square.and.arrow.down" : "doc")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(moleculeVM.isDragginFile ? .green : .secondary)
                                        Text(moleculeVM.isDragginFile ? "Drop file" : "Open file")
                                    }.onTapGesture {
                                        moleculeVM.openFileImporter.toggle()
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
                toolbars
                Spacer()
            }
            #endif
        }
        .sheet(isPresented: $moleculeVM.showPopover, onDismiss: {}, content: {
            moleculeVM.popoverContent
        })
        .alert(isPresented: $moleculeVM.showErrorFileAlert) {
            Alert(title: Text("File error"), message: Text(moleculeVM.errorDescription), dismissButton: .default(Text("Ok")))
        }
        #if os(macOS)
        .onDrop(of: [.fileURL], delegate: moleculeVM)
        #else
        .onDrop(of: FileOpener.types, delegate: moleculeVM)
        #endif
        .frame(minWidth: 800, minHeight: 600)
        .fileImporter(isPresented: $moleculeVM.openFileImporter, allowedContentTypes: FileOpener.types) { fileURL in
            moleculeVM.handlePickedFile(fileURL)
        }
    }
}
