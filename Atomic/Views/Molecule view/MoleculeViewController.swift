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

class MoleculeViewModel: ObservableObject {
    
    @Published var showErrorFileAlert = false
    
    @Published var moleculeReady = false
    
    @Published var controller = RendererController()
        
    @Published var openFileImporter = false
    
    @Published var fileURL: URL? = nil
    
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
            stepSlider = Double(stepIndex)
        }
    }
    
    @Published var stepSlider = 0.0
    
//    func getFile(_ url: URL) {
//        resetFile()
//        self.fileURL = url
//        getMolecules(urlFile: url)
//    }
    
//    func getFromDrop(providers: [NSItemProvider]) {
//        providers.first?.loadInPlaceFileRepresentation(forTypeIdentifier: "public.data", completionHandler: { fileURL, completed, error in
//            guard let decriptedUrl = fileURL else {return}
//            print("*** URL from drop: \(decriptedUrl)")
//            DispatchQueue.main.sync {
//                self.getFile(decriptedUrl)
//            }
//        })
//
//    }
    
    func handleDrop(_ drop: [NSItemProvider]) {
        loading = true
        FileOpener.getURL(fromDroppedFile: drop) { url in
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
        steps = []
        stepIndex = 0
    }
    
}
