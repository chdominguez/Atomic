//
//  XYZReader.swift
//  Atomic_ipad
//
//  Created by Christian Dominguez on 21/3/22.
//

import Foundation
import SceneKit

class XYZReader {
    
    private var natoms = 0
    private var currentMolecule: Molecule? = nil
    private var stepNumber = 0
    private var currentLine = 0
    
    private let fileInput: [String]
    public var steps: [Step] = []
    
    init(file: String) {
        self.fileInput = file.components(separatedBy: "\n")
    }
    
    func getSteps() throws -> [Step] {
        do {
            try readSteps()
            return self.steps
        } catch let error as ReadingErrors {
            ErrorManager.shared.lineError = currentLine
            throw error
        }
    }
    
    private func readSteps() throws {
        var natoms = 0
        for line in fileInput {
            currentLine += 1
            let splitted = line.components(separatedBy: " ")
            if splitted.count == 1 {
                guard let _ = currentMolecule else {currentMolecule = Molecule(); continue}
                let step = Step(stepNumber: stepNumber, molecule: currentMolecule)
                steps.append(step)
                currentMolecule = Molecule()
            }
            else if line.contains("Atom") {
                continue
            }
            else if splitted.count == 4 {
                natoms += 1
                var currentElement: Element = .hydrogen
                
                guard let atomNumber = Int(splitted[0]) else {throw ReadingErrors.xyzError}
                
                for atom in Element.allCases {
                    if atomNumber == atom.atomicNumber {
                        currentElement = atom
                        break
                    }
                }
                
                guard let x = Float(splitted[1]), let y = Float(splitted[2]), let z = Float(splitted[3]) else {throw ReadingErrors.xyzError}
                
                let position = SCNVector3(x, y, z)
                
                let atom = Atom(position: position, type: currentElement, number: atomNumber)
                currentMolecule?.atoms.append(atom)
            }
            else {
                throw ReadingErrors.xyzError
            }
            
        }
    }
}

