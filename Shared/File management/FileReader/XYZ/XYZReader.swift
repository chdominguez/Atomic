//
//  XYZReader.swift
//  Created by Christian Dominguez on 21/3/22.
//

import ProteinKit // For SCN3Vectors used for atoms positions

extension BaseReader {
    internal func readXYZSteps() throws {
        // Assign the XYZ error for cleaner code
        let xyzError = AtomicErrors.xyzError
        
        // Variable to save current step atom positions
        var currentMolecule: Molecule? = nil
        
        // Variable to count the current step. Initialized to 1
        var stepNumber = 1
        
        // For molecular dynamics simulations, account for the time step.
        var timeStep: Int? = nil
        
        // Keep track of the number of atoms
        var numberOfAtoms = 0
        
        var skipLine = false
        
        for line in splitFile! {
            
            increaseProgress()
            
            //Increment current line by 1 to keep track if an error happens
            errorLine += 1
            
            if line.contains("VEC") {continue}
            
            let filteredLine = line.replacingOccurrences(of: "\t", with: "")
            
            let splitted = filteredLine.split(separator: " ") // Split the line to verify what's on the input
            
            // Continue the loop on empty line
            if splitted.isEmpty {skipLine = false; continue}
                    
            // If the line contains 1 element, then it's the atom count for that molecule
            guard splitted.count > 1 else {
                
                // Check whether its the first molecule and assign a new Molecule to currentMolecule.
                if currentMolecule == nil {
                    currentMolecule = Molecule()
                    skipLine = true // Next line should not contain atom info
                    continue
                }
                
                // If an existing Molecule is present, then append the previous molecule to Steps and create a new instance.
                let step = Step();
                step.stepNumber = stepNumber
                step.molecule = currentMolecule
                step.timestep = timeStep
                steps.append(step)
                currentMolecule = Molecule() // Append the new step and reinit the variable with a new molecule
                stepNumber += 1 // Increment the number of steps for the next one
                skipLine = true // Next line should not contain atom info
                continue // Skip loop to next line
            }
            
            if skipLine {
                // Obtain timestep for Molecular dynamics simulations
                guard !filteredLine.contains("Timestep") else {
                    guard let time = Int(splitted.last!) else {throw xyzError}
                    timeStep = time
                    continue // Skip loop as in timestep lines that is the only useful information
                }
                skipLine = false
                continue
            }
            

            // Saving atom coordinates
            guard let currentElement = getAtom(fromString: String(splitted[0])),
                  let x = Float(splitted[1]),
                  let y = Float(splitted[2]),
                  let z = Float(splitted[3])
            else {throw xyzError}
            
            numberOfAtoms += 1
            
            let position = SCNVector3(x, y, z) // Position for rendering the atoms later
            
            let atom = Atom(position: position, type: currentElement, number: numberOfAtoms) // Generating atom instance and appending it to the current molecule
            
            guard let _ = currentMolecule else {throw xyzError} // Something went wrong if the molecule at this point is not assigned. Possible an error on the XYZ file.
            currentMolecule!.atoms.append(atom)
        }        
        // Save final step and end the function
        guard let _ = currentMolecule else {throw xyzError}
        let step = Step()
        step.stepNumber = stepNumber
        step.molecule = currentMolecule
        step.isFinalStep = true
        step.timestep = timeStep
        steps.append(step)
    }
}
