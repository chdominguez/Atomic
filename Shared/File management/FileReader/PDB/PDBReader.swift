//
//  PDBReader.swift
//  Atomic_ipad
//
//  Created by Christian Dominguez on 21/3/22.
//

import Foundation
import SceneKit


class PDBreader {
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
        currentMolecule = Molecule()
        for line in fileInput {
            currentLine += 1
            if line.prefix(4) == "ATOM" {
                let splitted = line.split(separator: " ")
                var column = 6
                /// TO DO : Improve this PDB reader for different columns
                if splitted.count == 10 { // Special case for amber generated PDBS
                    column = 5
                }
                
                guard let natoms = Int(splitted[1]) else {ErrorManager.shared.lineError = currentLine; throw ReadingErrors.pdbError}
                
                let atomType = splitted[2].prefix(1)
            
                var currentElement: Element = .hydrogen
                
                for atom in Element.allCases {
                    if atomType == atom.rawValue {
                        currentElement = atom
                        break
                    }
                }
                
                guard let x = Float(splitted[column]), let y = Float(splitted[column + 1]), let z = Float(splitted[column + 2]) else {throw ReadingErrors.pdbError}
                
                let position = SCNVector3(x, y, z)
                
                let atom = Atom(position: position, type: currentElement, number: natoms)
                currentMolecule?.atoms.append(atom)
            }
        }
        let step = Step(molecule: currentMolecule)
        steps.append(step)
    }
}
