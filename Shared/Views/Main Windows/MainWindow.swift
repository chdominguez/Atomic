//
//  MainWindow.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/9/21.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct MainWindow: View {
    
    @ObservedObject var settings = GlobalSettings.shared
    @StateObject var controller = AtomicMainController()
    
    /// Keep track if the app is minimized on iOS.
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        content
        // Minimum size of macOS window
        .frame(minWidth: 800, minHeight: 600)
        // Assign modifiers to import and export files
        .fileExporter(isPresented: $controller.fileExporter,
                      document: controller.fileToSave,
                      contentType: UTType(filenameExtension: "xyz")!,
                      defaultFilename: "molecule")
                      {_ in}
        .fileImporter(isPresented: $controller.openFileImporter,
                      allowedContentTypes: AtomicFileOpener.shared.types)
                      { fileURL in controller.handlePickedFile(fileURL) }
        // Assign alert for error in the files
        .alert(isPresented: $controller.showErrorFileAlert) { alert }
        // Custom view modifier for allowing dropping on macOS and iOS
        .onDropOfAtomic(delegate: controller)
        #if os(macOS)
        // Obtaining the NSWindow instance associated with this view
        .background(WindowAccessor(associatedController: controller))
        #elseif os(iOS)
        // Assigning the root view a sheet for displaying new views as a "little window inside the app".
        .sheet(isPresented: $controller.showSheet, content: {controller.sheetContent})
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                InstanceManager.shared.currentController = controller
            }
        }
        #endif
        
    }
    
}

/// Extension for assigning modifiers to the main view easily
extension MainWindow {
    
    // MainWindow's content
    #warning("TODO: Clean main window view")
    private var content: some View {
        ZStack {
            if controller.fileReady {
                Molecule3DView(controller: controller.renderer!)
            }
            else {
                VStack(spacing: 50) {
                    WelcomeMessage()
                    ZStack {
                        if controller.loading {
                            VStack {
                                ProgressView()
                                Text("Reading file")
                            }
                        }
                        else {
                            HStack(spacing: 100) {
                                VStack {
                                    Image(systemName: "plus").resizable().scaledToFit().frame(width: 100, height: 100).foregroundColor(.secondary)
                                    Text("New")
                                }.onTapGesture {
                                    controller.newFile()
                                }
                                ZStack {
                                    VStack {
                                        Image(systemName: controller.isDragginFile ? "square.and.arrow.down" : "doc")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(controller.isDragginFile ? .green : .secondary)
                                        Text(controller.isDragginFile ? "Drop file" : "Open file")
                                    }.onTapGesture {
                                        controller.openFileImporter.toggle()
                                    }
                                }
                                VStack {
                                    Image(systemName: "gear").resizable().scaledToFit().frame(width: 100, height: 100).foregroundColor(.secondary)
                                    Text("Settings")
                                }.onTapGesture {
                                    #if os(macOS)
                                    SettingsView().openNewWindow(type: .settings)
                                    #elseif os(iOS)
                                    SettingsView().openNewWindow(controller: controller)
                                    #endif
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
                iOSToolBarReplacement
                Spacer()
            }
            #endif
        }
    }
    
    private var alert: Alert {
        Alert(title: Text("File error"),
              message: Text(controller.errorDescription),
              dismissButton: .default(Text("Ok")))
    }
    
}

