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
    
    func getFile(_ result: Result<URL, Error>) {
        resetFile()
        self.fileURL = FileOpener.getFile(res: result)
        getMolecules()
    }
    
    private func getMolecules() {
        loading = true
        DispatchQueue.main.async { [self] in
            let reader = MolReader()
            guard let steps = reader.readFile(fileURL!) else {fatalError()}
            print("Steps: \(steps)")
            self.steps = steps
            controller.molecule = steps[0].molecule
            self.loading = false
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
    
    private func resetFile() {
        fileURL = nil
        steps.removeAll()
        stepIndex = 0
    }   
    
}
