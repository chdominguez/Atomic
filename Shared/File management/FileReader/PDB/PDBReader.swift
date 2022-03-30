//
//  PDBReader.swift
//  Atomic_ipad
//
//  Created by Christian Dominguez on 21/3/22.
//

import SceneKit


extension BaseReader {
    internal func readPDBSteps() throws {
        // Assign the PDB error for cleaner code
        let pdbError = ReadingErrors.pdbError
        
        // Variable to save current step atom positions
        var currentMolecule = Molecule()
        
        // Some pdbs have variable column size, with data placed in different columns
        var ncolumns = 0 // Number of columns
        var dI = 0 // Distance index. Column where X coordinates are.
        
        // Keep track of the number of atoms
        var natoms = 0
        
        for line in openedFile {
            
            //Increment current line by 1 to keep track if an error happens
            errorLine += 1
            
            let splitted = line.split(separator: " ")
            
            /// TO DO: PDB helix, residues, solvent...
            // Temporal implementation of PDB files.
            switch splitted.first {
            //MARK: ATOM
            case "ATOM":
                do {
                    //Increment number of atoms
                    natoms += 1
                    // First check number of columns to see if it's a compatible PDB
                    if ncolumns == 0 {
                        ncolumns = splitted.count
                        switch ncolumns {
                        case 12:
                            dI = 6 // X values start at index 6
                        case 10:
                            dI = 5 // X values start at index 5
                            /// TO DO : Improve this PDB reader for different columns
                        default:
                            ErrorManager.shared.lineError = errorLine
                            ErrorManager.shared.errorDescription = "Invalid PDB"
                            throw pdbError
                        }
                    }

                    guard let element = getAtom(fromString: String(splitted[2])), let x = Float(splitted[dI]), let y = Float(splitted[dI + 1]), let z = Float(splitted[dI + 2]) else {throw pdbError}
                    
                    let position = SCNVector3(x, y, z)
                    
                    let atom = Atom(position: position, type: element, number: natoms)
                    currentMolecule.atoms.append(atom)
                }
            //MARK: Default
            default: continue
            }
        }
        
        // Create the step corresponding to this protein
        let step = Step(molecule: currentMolecule, isFinalStep: true)
        self.steps.append(step)
    }
    
    
}
