//
//  MioleculeViewController.swift
//  MioleculeViewController
//
//  Created by Christian Dominguez on 22/8/21.
//

import Foundation
import SwiftUI
import SceneKit
import UniformTypeIdentifiers
import Combine

class MoleculeViewModel: ObservableObject, DropDelegate {
    
    static let shared = MoleculeViewModel()
    
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
    
    @Published var fileAsString: String? = nil
    
    var gReader: GaussianReader? = nil
    
    var errorDescription = ""
    
    var popoverContent: AnyView = AnyView(EmptyView())
    
    func handlePickedFile(_ picked: Result<URL, Error>) {
        loading = true
        DispatchQueue.global(qos: .background).async { [self] in
            guard let url = FileOpener.getFileURLForPicked(picked) else {
                showErrorFileAlert = true
                return
            }
            processFile(url: url)
        }
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
                guard url.startAccessingSecurityScopedResource() else {
                    showErrorFileAlert = true
                    return
                }
                let fileString = try FileOpener.getFileAsString(from: url)
                guard let steps = try FileOpener.getMolecules(fromFileURL: url) else {return}
                DispatchQueue.main.sync {
                    self.fileAsString = fileString
                    if steps.isEmpty {
                        errorDescription = "Could not load any molecule"
                        showErrorFileAlert = true
                        loading = false
                    }
                    else {
                        if !steps.last!.isFinalStep {
                            errorDescription = "Job did not terminate"
                            showErrorFileAlert = true
                        }
                        initializeController(steps: steps)
                        fileURL = url
                        fileReady = true
                        loading = false
                    }
                }
                url.stopAccessingSecurityScopedResource()
            }
            catch {
                DispatchQueue.main.sync {
                    self.errorDescription = error.localizedDescription + " at line:  \(ErrorManager.shared.lineError)"
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
                for allowedExtensions in FileOpener.types {
                    let flag = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType == allowedExtensions
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


