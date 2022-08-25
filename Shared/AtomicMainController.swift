//
//  MioleculeViewController.swift
//  MioleculeViewController
//
//  Created by Christian Dominguez on 22/8/21.
//

import SwiftUI
import ProteinKit
import UniformTypeIdentifiers

class AtomicMainController: ObservableObject {
    
    //MARK: Init
    
    private var settings = GlobalSettings.shared
    
    /// Initializes the renderer that manages the 3D view with the given steps
    private func initializeController(steps: [Step]) {
        self.renderer = MoleculeRenderer(steps)
    }
    
    /// ID for keeping track of opened controllers
    var id = UUID()
    var renderer: MoleculeRenderer? = nil
    var fileURL: URL? = nil {
        didSet {
            guard let fileURL = fileURL else {
                return
            }
            settings.savedRecents.addBookmark(for: fileURL)
        }
    }
    
    // Drag and drop related variables
    @Published var isDragginFile: Bool  = false
    /// Used to animate the view with a green dashed moving line
    @Published var phase: CGFloat = 0
    
    // If ture, the loading screen shows
    @Published var loading: Bool = false
    
    @Published var showErrorAlert: Bool  = false
    @Published var fileReady: Bool  = false
    @Published var openFileImporter: Bool  = false
    
    @Published var fileExporter: Bool = false
    @Published var fileToSave: xyzFile? = nil
    
    /// Opened file. In case the user wants to see the file
    @Published var fileAsString: String? = nil
    
    // Base reader class for reading files and handling Steps
    var BR: BaseReader? = nil
    
    /// Error shown when the opened file cannot be loaded
    var errorDescription = ""
    
    /// The content to be displayed on a sheey. Used mainly in iOS when a window cannot be displayed
    var sheetContent: AnyView = AnyView(EmptyView())
    @Published var showSheet: Bool = false
    
    //MARK: File manager
    
    func newFile() {
        resetFile()
        let emptyStep = Step()
        renderer = MoleculeRenderer([emptyStep])
        fileReady = true
    }
    
    func saveFile(_ file: xyzFile) {
        fileToSave = file
        fileExporter = true
    }
    
    func handlePickedFile(_ picked: Result<URL, Error>) {
        fileReady = false
        loading = true
        guard let url = AtomicFileOpener.getFileURLForPicked(picked) else {
            showErrorAlert = true
            return
        }
        processFile(url: url)
    }
    
    func resetFile() {
        fileAsString = nil
        renderer = nil
        fileReady = false
        fileURL = nil
        BR = nil
    }
    
    func processFile(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                guard url.startAccessingSecurityScopedResource() else {
                    DispatchQueue.main.sync {
                        errorDescription = "Cannot access file"
                        showErrorAlert = true
                        loading = false
                    }
                    return
                }
                let fileString = try AtomicFileOpener.getFileAsString(from: url)
                self.BR = try BaseReader(fileURL: url)
                try BR?.readSteps()
                
                guard let BR = BR else {
                    throw AtomicErrors.internalFailure
                }
                #warning("TODO: Clean up this becasue BaseReader makes this easy")
                url.stopAccessingSecurityScopedResource()
                DispatchQueue.main.sync {
                    self.fileAsString = fileString
                    if BR.steps.isEmpty {
                        errorDescription = "Could not load any molecule"
                        showErrorAlert = true
                        loading = false
                    }
                    else {
                        if !BR.steps.last!.isFinalStep {
                            errorDescription = "Job did not terminate"
                            showErrorAlert = true
                        }
                        initializeController(steps: BR.steps)
                        fileURL = url
                        fileReady = true
                        loading = false
                    }
                }
            }
            catch {
                DispatchQueue.main.sync {
                    self.errorDescription = error.localizedDescription + " at line:  \(BR?.errorLine ?? 0) \n \(ErrorManager.shared.errorDescription ?? "Error") "
                    self.showErrorAlert = true
                    self.loading = false
                }
            }
        }
    }
}

//MARK: Drop delegate
extension AtomicMainController: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        fileReady = false
        loading = true
        let drop = info.itemProviders(for: [.fileURL])
        AtomicFileOpener.getURL(fromDroppedFile: drop) { url in
            self.processFile(url: url)
        }
        return true
    }
    
    func dropExited(info: DropInfo) {
        isDragginFile = false
    }
    
    /* Thanks Asperi from
     
     https://stackoverflow.com/questions/69771509/is-anyone-able-to-restrict-the-type-of-the-objects-dropped-on-the-mac-in-swiftui
     
     https://stackoverflow.com/users/12299030/asperi
     
     For this simple validation code. */
    
    func validateDrop(info: DropInfo) -> Bool {
        // find provider with file URL
        guard info.hasItemsConforming(to: [.fileURL]) else { return false }
        guard let provider = info.itemProviders(for: [.fileURL]).first else { return false }
        
        var result = false
        if provider.canLoadObject(ofClass: String.self) {
            let group = DispatchGroup()
            group.enter()     // << make decoding sync
            
            // decode URL from item provider
            _ = provider.loadObject(ofClass: String.self) { value, _ in
                defer { group.leave() }
                guard let fileURL = value, let url = URL(string: fileURL) else { return }
                
                // verify type of content by URL
                for allowedExtensions in AFE.allCases {
                    let flag = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType == UTType(filenameExtension: allowedExtensions.rawValue)
                    if flag == true {
                        result = flag ?? false
                    }
                }
            }
            // wait a bit for verification result
            _ = group.wait(timeout: .now() + 0.5)
        }
        if result {
            isDragginFile = true
        }
        return result
    }
}

