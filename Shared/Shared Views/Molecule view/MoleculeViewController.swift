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

class MoleculeViewModel: ObservableObject, DropDelegate {
    
    var timer = Timer()
    
    @Published var isPlaying = false
    
    @Published var showErrorFileAlert = false
    
    @Published var moleculeReady = false
    
    @Published var controller = RendererController()
        
    @Published var openFileImporter = false
    
    @Published var isDragginFile = false
    
    @Published var showFileMenu = false
    @Published var showEditMenu = false
    @Published var energy: Double = 0
    
    var fileURL: URL? = nil
    
    @Published var loading: Bool = false
    
    @Published var steps = [Step]() {
        didSet {
            if !steps.isEmpty {
                controller.molecule = steps[0].molecule
            }
        }
    }
    
    @Published var stepIndex: Int = 0 {
        didSet {
            let count = steps.count
            if stepIndex == count {
                stepIndex = 0
            }
            if stepIndex == -1 {
                stepIndex = count - 1
            }
            controller.molecule = steps[stepIndex].molecule
        }
    }
    
    @Published var stepSlider = 0.0
    
    func playAnimation() {
        if isPlaying {
            timer.invalidate()
        }
        else {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                self.stepIndex += 1
            }
        }
        isPlaying.toggle()
    }
        
    func handleDrop(_ drop: [NSItemProvider]) {
        loading = true
        FileOpener.getURL(fromDroppedFile: drop) { url in
            //        guard let fileURL = fileURL else {
            //            return
            //        }
            DispatchQueue.main.sync {
                guard let steps = FileOpener.getMolecules(fromFileURL: url) else {return}
                self.steps = steps
                self.moleculeReady = true
                self.loading = false
            }
        }
    }
    
    func handlePickedFile(_ picked: Result<URL, Error>) {
        guard let url = FileOpener.getFileURLForPicked(picked) else {
            showErrorFileAlert = true
            return
        }
        guard url.startAccessingSecurityScopedResource() else {
            showErrorFileAlert = true
            return
        }
        guard let steps = FileOpener.getMolecules(fromFileURL: url) else {
            showErrorFileAlert = true
            return
        }
        url.stopAccessingSecurityScopedResource()
        self.resetFile()
        self.steps = steps
        self.moleculeReady = true
    }

    
    
    func indexButton(_ stepButton: StepButton) {
        switch stepButton {
        case .next:
            if stepIndex == steps.count - 1 {
                stepIndex = 0
            }
            else {
                stepIndex += 1
            }
        case .back:
            if stepIndex == 0 {
                stepIndex = steps.count - 1
            }
            else {
                stepIndex -= 1
            }
        }
    }
    
    enum StepButton {
        case next
        case back
    }
    
    func resetFile() {
        controller.resetRenderer()
        moleculeReady = false
        fileURL = nil
        stepIndex = 0
        steps = []
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.loading = true
        let drop = info.itemProviders(for: [.fileURL])
        FileOpener.getURL(fromDroppedFile: drop) { url in
            DispatchQueue.main.sync {
                guard let steps = FileOpener.getMolecules(fromFileURL: url) else {return}
                self.steps = steps
                self.moleculeReady = true
                self.loading = false
            }
        }
        return true
    }
    
    /* Thanks Asperi from
     
     https://stackoverflow.com/questions/69771509/is-anyone-able-to-restrict-the-type-of-the-objects-dropped-on-the-mac-in-swiftui
     
     https://stackoverflow.com/users/12299030/asperi
     
     For this simple validation code.
    */
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
    
    func dropExited(info: DropInfo) {
        isDragginFile = false
    }
    
}


