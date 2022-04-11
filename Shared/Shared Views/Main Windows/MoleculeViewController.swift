//
//  MioleculeViewController.swift
//  MioleculeViewController
//
//  Created by Christian Dominguez on 22/8/21.
//

import SwiftUI
import SceneKit
import UniformTypeIdentifiers

class MoleculeViewModel: ObservableObject, DropDelegate, Identifiable {
    
    let id = UUID()
    
    var renderer: RendererController? = nil
    var fileURL: URL? = nil
    
    @Published var loading: Bool = false
    @Published var showErrorFileAlert: Bool  = false
    @Published var fileReady: Bool  = false
    @Published var openFileImporter: Bool  = false
    @Published var isDragginFile: Bool  = false
    @Published var showFileMenu: Bool  = false
    @Published var showEditMenu: Bool = false
    @Published var phase: CGFloat = 0
    @Published var showPopover: Bool = false
    @Published var fileExporter: Bool = false
    @Published var fileToSave: xyzFile? = nil
    
    @Published var fileAsString: String? = nil
    
    // Base reader class for reading files and handling Steps
    var BR: BaseReader? = nil
    
    #if os(macOS)
    var openedWindows: [WindowTypes] = []
    #endif
    
    var errorDescription = ""
    
    var sheetContent: AnyView = AnyView(EmptyView())
    
    func newFile() {
        fileURL = nil
        fileAsString = nil
        fileReady = true
        let emptyStep = Step()
        renderer = RendererController([emptyStep])
    }
    
    func saveFile(_ file: xyzFile) {
        fileToSave = file
        fileExporter = true
    }
    
    func handlePickedFile(_ picked: Result<URL, Error>) {
        loading = true
        guard let url = FileOpener.getFileURLForPicked(picked) else {
            showErrorFileAlert = true
            return
        }
        guard url.startAccessingSecurityScopedResource() else {
            DispatchQueue.main.sync {
                showErrorFileAlert = true
                loading = false
            }
            return
        }
        processFile(url: url)
    }

    private func initializeController(steps: [Step]) {
        self.renderer = RendererController(steps)
    }
    
    func resetFile() {
        renderer = nil
        fileReady = false
        fileURL = nil
    }
    
    private func processFile(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                let fileString = try FileOpener.getFileAsString(from: url)
                let BR = try BaseReader(fileURL: url)
                try BR.readSteps()
                #warning("TODO: Clean up this becasue BaseReader makes this easy")
                self.BR = BR
                url.stopAccessingSecurityScopedResource()
                DispatchQueue.main.sync {
                    self.fileAsString = fileString
                    if BR.steps.isEmpty {
                        errorDescription = "Could not load any molecule"
                        showErrorFileAlert = true
                        loading = false
                    }
                    else {
                        if !BR.steps.last!.isFinalStep {
                            errorDescription = "Job did not terminate"
                            showErrorFileAlert = true
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
                    self.errorDescription = error.localizedDescription + " at line:  \(ErrorManager.shared.lineError) \n \(ErrorManager.shared.errorDescription ?? "Error") "
                    self.showErrorFileAlert = true
                    self.loading = false
                }
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        fileReady = false
        loading = true
        let drop = info.itemProviders(for: [.fileURL])
        FileOpener.getURL(fromDroppedFile: drop) { url in
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


