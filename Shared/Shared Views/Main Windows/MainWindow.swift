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
        .onDrop(of: [.fileURL], delegate: moleculeVM)
        .frame(minWidth: 800, minHeight: 600)
        .fileImporter(isPresented: $moleculeVM.openFileImporter, allowedContentTypes: FileOpener.types) { fileURL in
            moleculeVM.handlePickedFile(fileURL)
        }
    }
}
