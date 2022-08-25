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
    
    @State var newTapped = false
    @State var openTapped = false
    @State var settingsTapped = false
    
    let rectangle = RoundedRectangle(cornerRadius: 25)
    
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
            .alert(isPresented: $controller.showErrorAlert) { alert }
        // Custom view modifier for allowing dropping on macOS and iOS
            .onDropOfAtomic(delegate: controller)
        // iOS: Handle opened files from the Files app or other sources
        // macOS: Handle dragged files to the icon or with "open with... Atomic"
            .onOpenURL { url in
                controller.processFile(url: url)
            }
#if os(macOS)
        // Obtaining the NSWindow instance associated with this view
            .background(WindowAccessor(associatedController: controller))
#elseif os(iOS)
        // Assigning the root view a sheet for displaying new views as a "little window inside the app".
            .sheet(isPresented: $controller.showSheet, content: {controller.sheetContent})
        // Detect if the app has become active to set the active controller
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    InstanceManager.shared.currentController = controller
                }
            }
#endif
    }
    
    // The alert presented when there is any error
    private var alert: Alert {
        Alert(title: Text("Error"),
              message: Text(controller.errorDescription),
              dismissButton: .default(Text("Ok")))
    }
    
}

/// Extension for assigning modifiers to the main view easily
extension MainWindow {
    
    // MainWindow's content
    private var content: some View {
        ZStack {
            if controller.fileReady {
                Molecule3DView(controller: controller.renderer!, firstMoleculeName: controller.fileURL?.lastPathComponent ?? "Molecule")
#if os(iOS)
                VStack {
                    iOSToolBarReplacement
                    Spacer()
                }
#endif
            }
            else {
                    VStack {
                        Spacer()
                        HStack {
                            WelcomeMessage()
                            //#if os(macOS)
                            Spacer().frame(width: 50)
                            if !settings.savedRecents.urls.isEmpty {
                                recentsView
                            }
                            //#endif
                        }
                        Spacer()
                        mainScreen.padding(.vertical, 20)
                        Spacer().frame(height: 100)
                    }
            }
        }
    }
    
    private var recentsView: some View {
        RecentsView(mainController: controller)
    }
    private var mainScreen: some View {
        VStack(spacing: 50) {
            if controller.loading {
                CirclingHydrogen(scale: 2)
                Text("Reading file...")
            }
            else {
                HStack(spacing: 100) {
                    newButton
                    openButton
                    settingsButton
                }
            }
            
        }
        .frame(width: 120, height: 120)
        .padding()
    }
    
    private var newButton: some View {
        Button {
            controller.newFile()
        } label: {
            ZStack {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.primary)
                    .scaleEffect(newTapped ? 1.2 : 1)
                    .animation(.spring(), value: newTapped)
                Text("New")
                    .bold()
                    .offset(x: 0, y: 100)
            }
        }
        .neumorphicAtomicButton(rectangle, padding: 30)
        .onHover { newTapped = $0 }
    }
    
    private var openButton: some View {
        Button {
            controller.openFileImporter.toggle()
        } label: {
            ZStack {
                if controller.isDragginFile {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                        .scaleEffect(openTapped ? 0.8 : 1)
                        .animation(.spring(), value: openTapped)
                } else {
                    Image(systemName: "doc")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.primary)
                        .scaleEffect(openTapped ? 0.8 : 1)
                        .offset(x: openTapped ? 10 : 0, y: openTapped ? -10 : 0)
                        .animation(.spring(), value: openTapped)
                    Image(systemName: "doc")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(x: openTapped ? -10 : 0, y: openTapped ? 10 : 0)
                        .foregroundColor(.primary)
                        .scaleEffect(openTapped ? 0.8 : 1)
                        .animation(.spring(), value: openTapped)
                }
                Text(controller.isDragginFile ? "Drop file" : "Open file")
                    .bold()
                    .offset(x: 0, y: 100)
            }
        }
        .neumorphicAtomicButton(rectangle, padding: 30)
        .scaleEffect(controller.isDragginFile ? 0.9 : 1)
        .animation(.easeOut, value: controller.isDragginFile)
        .onHover { openTapped = $0 }
    }
    
    private var settingsButton: some View {
        Button {
            settingsTapped.toggle()
#if os(macOS)
            SettingsView().openNewWindow(type: .settings)
#elseif os(iOS)
            SettingsView().openNewWindow(controller: controller)
#endif
        } label: {
            ZStack {
                Image(systemName: "gear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.primary)
                    .rotationEffect(settingsTapped ? Angle(degrees: 60) : Angle(degrees: 0))
                    .scaleEffect(settingsTapped ? 1.2 : 1)
                    .animation(.spring(), value: settingsTapped)
                Text("Settings")
                    .bold()
                    .offset(x: 0, y: 100)
            }
        }
        .neumorphicAtomicButton(rectangle, padding: 30)
        .onHover { settingsTapped = $0 }
    }
}

//MARK: Welcome message
struct WelcomeMessage: View {
    var body: some View {
        HStack {
            VStack {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x: 0, y: 35)
                Text("Atomic")
                    .font(.system(size: 100))
                Text("Molecular editor")
                    .font(.title)
            }
        }.padding()
    }
}

struct RecentsView: View {
    @ObservedObject var mainController: AtomicMainController
    @ObservedObject var settings = GlobalSettings.shared
    var body: some View {
        if settings.savedRecents.urls.isEmpty {
            Text("No recent files")
        } else {
            VStack(alignment: .leading) {
                Text("Recent files:").font(.title)
                ScrollView {
                    ForEach(settings.savedRecents.urls, id: \.self) { url in
                        VStack(alignment: .trailing) {
                                HStack {
                                    Image("atomic-file")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                        .padding(.vertical, 5)
                                    Text("\(url.lastPathComponent)")
                                    Spacer()
                                }.background(RoundedRectangle(cornerRadius: 10).fill(Color.neumorEnd))
                                    .frame(width: 300)
                            }
                        .onTapGesture {
                                mainController.processFile(url: url)
                            }
                    }
                }.frame(height: 220)
            }
        }
    }
}


struct preview: PreviewProvider {
    static var previews: some View {
        Group {
            MainWindow()
        }
    }
}
