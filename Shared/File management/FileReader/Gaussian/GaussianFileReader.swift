//
//  GaussianLOG.swift
//  Atomic
//
//  Created by Christian Dominguez on 28/12/21.
//

import SceneKit

extension BaseReader {
    
    #warning("TODO: Gaussian separators. Maybe RegEx a better approach?")
    // Typealias for the gaussian separators. Uses less coding space
    private typealias GS = GaussianSeparators
    
    // These are some of the important strings that appear on a Gaussian .log file. They can be used to track the output.
    private enum GaussianSeparators: String, CaseIterable {
        // When writing the coordinates of each step, Gaussian writes them in a box with this title.
        case standardOrientation    = "                         Standard orientation:                         "
        // Then, there are three separators like this that encampsulate the coordinates.
        case orientationSeparator   = " ---------------------------------------------------------------------"
        // The keywords from the input file are locathed between two of those.
        case inputKeywords1         = " ----------------------------------------------------------------------"
        case inputKeywords2         = " --------------------------------------------------"
        // After two of these lines, the inputfile that was given to Gaussian is written back into the log file.
        case asterisc               = " ******************************************"
        // The title of the job is written between two of those.
        case title                  = " ----------"
        case title2                 = " ------------"
    }

    internal func readGaussianLogSteps() throws {
        
        // The resulting input file written as a GJF file
        var inputFile: String = ""
        
        // Variables for reading the output file
        var orientSeparators: Int  = 0
        var jobNumber:        Int  = 1
        var readFinished:     Bool = false
        var orientCoords:     Bool = false
        var startStep:        Bool = false
        var standardOrient:   Bool = false
        
        var finalString: String = ""
        
        // All of the steps in the output file are saved in an array of Step objects.
        var steps: [Step] = []
        var currentMolecule = Molecule()
        // The current step that is going to be appended
        var currentStep: Step? = nil
        
        // Error handling
        var readError: ReadingErrors? = nil
        
        // Variables for reading the input Gaussian file located inside the log file
        var asteriscs:       Int  =  0
        var inputSeparators: Int  =  0
        var titleSeparators: Int  =  0
        var readInput:       Bool = false
        var readTitle:       Bool = false
        var readInputCoords: Bool = false
        var readingKeywords: Bool = false
        var readOldGeom:     Bool = false
        var didReadInput:    Bool = false
        var chkGeom:         Bool = false
        
        for line in openedFile {
            errorLine += 1
            if didReadInput {
                //MARK: Read log file
                switch line {
                case GS.standardOrientation.rawValue:
                    standardOrient = true
                    if currentStep == nil {currentStep = Step()}
                case GS.orientationSeparator.rawValue:
                    if standardOrient { // Refactor all of this please...
                        orientSeparators += 1
                        if orientSeparators == 2 {orientCoords = true}
                        if orientSeparators == 3 {
                            orientCoords = false
                            standardOrient = false
                            orientSeparators = 0

                            guard let _ = currentStep else {throw ReadingErrors.internalFailure}
                            currentStep!.jobNumber = jobNumber
                            currentStep!.molecule = currentMolecule
                            self.steps.append(currentStep!)
                            currentStep = Step()
                            currentMolecule = Molecule()
                            
                        }
                    }
                default:
                    if orientCoords {
                        let atom = try gaussInputOrientationToAtom(line)
                        currentMolecule.atoms.append(atom)
                    }
                    if line.contains("Frequencies") {
                        let components = line.split(separator: " ")
                        guard let freq1 = Double(components[2]), let freq2 = Double(components[3]), let freq3 = Double(components[4]) else {throw ReadingErrors.badFreqs}
                        guard let _ = currentStep else {throw ReadingErrors.badFreqs}
                        if let _ = currentStep!.frequencys {
                            currentStep!.frequencys?.append(contentsOf: [freq1, freq2, freq3])
                        }
                        else  {
                            currentStep!.frequencys = []
                            currentStep!.frequencys!.append(contentsOf: [freq1, freq2, freq3])
                        }
                        break
                            
                    }
                    
                    if line.contains("A.U.") {
                        let components = line.split(separator: " ")
                        guard let energy = Double(components[4]) else {throw ReadingErrors.badEnergy}
                        currentStep?.energy = energy
                        break
                    }
                    
                    if line.contains("1\\1\\") { // When a job sucessfully ends, Gaussian writes the summary of the calculation, the proverb and finally "Normal termination of Gaussian.
                        readFinished = true
                    }
                    if readFinished {
                        finalString += line
                    }
                    if line.contains("\\@") {
                        guard let _ = currentStep else {throw ReadingErrors.internalFailure}
                        readFinished = false
                        let components = finalString.split(separator: "\\").reversed()
                        componentsLoop: for component in components {
                            for method in EnergyMethods.allCases {
                                if String(component).contains(method.rawValue) {
                                    let subcomponent = component.replacingOccurrences(of: " ", with: "").split(separator: "=")
                                    guard let energy = Double(subcomponent[1]) else {throw ReadingErrors.badTermination}
                                    currentStep!.energy = energy
                                    break componentsLoop
                                }
                            }
                        }
                        currentStep?.jobNumber = jobNumber
                        currentStep!.molecule = steps.last?.molecule
                        currentStep!.isFinalStep = true
                        steps.append(currentStep!)
                        currentStep = nil
                        jobNumber += 1
                    }
                    if line.contains("Initial command:") {
                        didReadInput = false
                        //skipOneGeom = true
                        #warning("TODO: Reimplement cleaning the variables")
                        //restoreInputReader()
                        inputFile += "\n--link1--\n"
                    }
                }
            }
            else {
                //MARK: Read input inside log file
                switch line {
                case GS.asterisc.rawValue:
                    asteriscs += 1
                    if asteriscs == 2 {
                        asteriscs = 0
                        readInput = true
                    }
                case GS.inputKeywords1.rawValue, GS.inputKeywords2.rawValue:
                    inputSeparators += 1
                    readingKeywords = true
                    if inputSeparators == 2 {
                        inputSeparators = 0
                        readInput = false
                        readingKeywords = false
                        inputFile += "\n"
                    }
                case GS.title.rawValue, GS.title2.rawValue:
                    readInput.toggle()
                    inputFile += "\n"
                default:
                    if line.contains("matrix") || line.contains("Will") {break}
                    if line.contains("old form") {
                        readOldGeom = true
                        break
                    }
                    if line.contains("Multiplicity") {
                        let splitted = line.split(separator: " ")
                        guard let charge = Int(splitted[2]),
                              let multiplicty = Int(splitted[5])
                        else {throw ReadingErrors.badInputCoords}
                        inputFile += "\(charge)" + " " + "\(multiplicty)" + "\n"
                        readInput = true
                        if chkGeom {
                            didReadInput = true
                        }
                        break
                    }
                    if readInput {
                        if line.isEmpty || line == " " || line.contains("Recover connectivity data from disk.") {
                            //self.steps = [try readgjfFile(fromlog: inputFile)]
                            didReadInput = true
                            break
                        }
                        if readingKeywords { // Necesssary for grouping all the keywords in one line without breaks.
                            inputFile += line.dropFirst()
                            if line.contains("check") {
                                chkGeom = true
                            }
                            break
                        }
                        if readOldGeom {
                            let separated = line.split(separator: ",")
                            let element = separated[0]
                            guard let x = Float(separated[2]), let y = Float(separated[3]), let z = Float(separated[4]) else {
                                throw ReadingErrors.badInputCoords
                            }
                            inputFile += element + "\t\t\t" + String(format: "%.7f", x) + "\t\t" + String(format: "%.7f", y) + "\t\t" + String(format: "%.7f", z) + "\n"
                            break
                        }
                        inputFile += line.dropFirst() + "\n"
                    }
                }
            }
        }
    }
    
    internal func gaussInputOrientationToAtom(_ line: String) throws -> Atom {
        
        var atom: Atom? = nil
        
        let components = line.split(separator: " ")
        guard let atomNumber = Int(components[0]) else {throw ReadingErrors.badInputCoords}
        
        for atomName in Element.allCases {
            if atomName.atomicNumber == Int(components[1]) {
                guard let x = Float(components[3]),
                      let y = Float(components[4]),
                      let z = Float(components[5])
                else {throw ReadingErrors.badInputCoords}
                #if os(macOS)
                let position = SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
                #else
                let position = SCNVector3(x: x, y: y, z: z)
                #endif
                atom = Atom(position: position, type: atomName, number: atomNumber)
                break
            }
        }
        guard let atom = atom else {throw ReadingErrors.badInputCoords}
        return atom
    }
    
    internal func readgjfFile(fromlog: String) throws -> Step {
        var molecule = Molecule()
        for line in fromlog.components(separatedBy: "\n") {
            guard let atom = try gjfToAtom(line: line, number: molecule.atoms.count + 1) else {continue}
            molecule.atoms.append(atom)
        }
        return Step(molecule: molecule)
    }
      
    
    internal func readGJFSteps() throws {
        var molecule = Molecule()
        for line in openedFile {
            guard let atom = try gjfToAtom(line: line, number: molecule.atoms.count + 1) else {continue}
            molecule.atoms.append(atom)
        }
        self.steps = [Step(molecule: molecule, isFinalStep: true)]
    }
    
    private func gjfToAtom(line: String, number: Int) throws -> Atom? {
        
        var atom: Atom?
        
        let fixedLine = line.replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\r", with: "")
        for atomName in Element.allCases {
            if fixedLine.contains("\(atomName.rawValue) ") {
                let lineComponents = fixedLine.split(separator: " ")
                guard let x = Float(lineComponents[1]), let y = Float(lineComponents[2]), let z = Float(lineComponents[3]) else {throw ReadingErrors.badInputCoords}
                #if os(macOS)
                let position = SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
                #else
                let position = SCNVector3(x: x, y: y, z: z)
                #endif
                atom = Atom(position: position, type: atomName, number: number)
            }
        }
        return atom
    }
    
}

enum ReadingErrors: Error, LocalizedError {
    
    // Gaussian Errors
    case badInputCoords
    case badTermination
    case badFreqs
    case badEnergy
    
    // XYZ errors
    case xyzError
    
    // PDB errors
    case pdbError
    
    // Misc
    case unknown
    case internalFailure
    case notImplemented
    
    
    public var errorDescription: String? {
        switch self {
        case .badInputCoords:
            return "Input coordinates are wrong"
        case .internalFailure:
            return "Internal failure"
        case .badTermination:
            return "Bad termination"
        case .badFreqs:
            return "Bad frequencies"
        case .badEnergy:
            return "Bad energy"
        
        case .xyzError:
            return "Error in xyz"
            
        case .pdbError:
            return "Error in pdb"
            
        case .unknown:
            return "Unknown error. Contact developer."
        case .notImplemented:
            return "File type not implemented yet!"
        }
    }
}
