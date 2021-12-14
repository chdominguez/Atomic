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
    
    func getFile(_ url: URL) {
        resetFile()
        self.fileURL = url
        getMolecules(urlFile: url)
    }
    
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
        var finalURL: URL? = nil
        let g = DispatchGroup()
        g.enter()
        drop.first?.loadInPlaceFileRepresentation(forTypeIdentifier: "public.data", completionHandler: { fileURL, completed, error in
            guard let fileURL = fileURL else {return}
            print("*** URL from drop: \(fileURL)")
            let textContent = try! String(contentsOf: fileURL)
            print(textContent)
            finalURL = fileURL
            g.leave()

        })
        g.notify(queue: .main) {
            self.fileURL = finalURL!
            self.getMolecules(urlFile: finalURL!)
            //mainWindowVM.userDidOpenAFile = true
        }
    }
    
    private func getMolecules(urlFile: URL) {
        print("*** Recieved file url is: \(urlFile)")
        loading = true
        DispatchQueue.main.async { [self] in
            let reader = MolReader()
            guard let steps = reader.readFile(urlFile) else {fatalError()}
            print("*** Steps: \(steps.first?.molecule.atoms)")
            self.steps = steps
            controller.molecule = steps[0].molecule
            self.loading = false
            print("*** Ended loading")
            self.moleculeReady = true
        }
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
        moleculeReady = false
        fileURL = nil
        steps.removeAll()
        stepIndex = 0
    }
    
}
