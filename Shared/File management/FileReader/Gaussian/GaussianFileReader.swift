//
//  GaussianLOG.swift
//  Atomic
//
//  Created by Christian Dominguez on 28/12/21.
//

import SceneKit

//Read a Gaussian log file
class GaussianReader {
    
    // Typealias for the gaussian separators. Uses less coding space
    private typealias GS = GaussianSeparators
    
    // The file as a string array separated by lines
    private let fileInput: [String]
    
    // Variables for reading the input Gaussian file located inside the log file
    private var asteriscs:       Int  =  0
    private var inputSeparators: Int  =  0
    private var titleSeparators: Int  =  0
    private var readInput:       Bool = false
    private var readTitle:       Bool = false
    private var readInputCoords: Bool = false
    private var readingKeywords: Bool = false
    private var readOldGeom:     Bool = false
    private var didReadInput:    Bool = false
    private var chkGeom:         Bool = false
    
    // The resulting input file written as a GJF file
    public var inputFile: String = ""
    
    // Variables for reading the output file
    private var orientSeparators: Int  = 0
    private var jobNumber:        Int  = 1
    private var readFinished:     Bool = false
    private var orientCoords:     Bool = false
    private var startStep:        Bool = false
    private var standardOrient:   Bool = false
    //private var skipOneGeom:      Bool = false // Used when multiple jobs in the same file to not store the input geometry. This geometry is the same from the last finished job.
    
    private var finalString: String = ""
    
    // All of the steps in the output file are saved in an array of Step objects.
    public var steps: [Step] = []
    private var currentMolecule = Molecule()
    // The current step that is going to be appended
    private var currentStep: Step? = nil
    
    // Error handling
    var readError: ReadingErrors? = nil
    var errorLine: Int = 0
    
    // Initialize the class with the input file
    init(file: String) {
        self.fileInput = file.components(separatedBy: "\n")
    }
    
    public func getStepsFromLog() throws {
        do {
            try readlogFile()
        }
        catch let error as ReadingErrors {
            ErrorManager.shared.lineError = errorLine
            readError = error
            throw error
        }
        catch {
            readError = .unknown
            throw error
        }
    }
    
    public func getStepsFromGJF() throws {
        do {
            try readgjfFile()
        }
        catch let error as ReadingErrors {
            readError = error
            ErrorManager.shared.lineError = errorLine
            throw error
        }
        catch {
            readError = .unknown
            throw error
        }
    }
    
    private func readlogFile() throws {
        for (n, line) in fileInput.enumerated() {
            errorLine = n
            if didReadInput {
                try readSteps(line)
            }
            else {
                try readInput(line)
            }
        }
    }
    
    private func readSteps(_ line: String) throws {
        switch line {
        case GS.standardOrientation.rawValue:
//            if skipOneGeom {
//                skipOneGeom = false
//                self.currentStep = Step()
//                break
//            }
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
                    self.currentStep!.molecule = currentMolecule
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
                restoreInputReader()
                inputFile += "\n--link1--\n"
            }
        }
    }
    
    private func readInput(_ line: String) throws {
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
    
    private func gaussInputOrientationToAtom(_ line: String) throws -> Atom {
        
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
                atom = Atom(id: UUID(), position: position, type: atomName, number: atomNumber)
            }
        }
        guard let atom = atom else {throw ReadingErrors.badInputCoords}
        return atom
    }
    
    private func readgjfFile() throws {
        var molecule = Molecule()
        for line in fileInput {
            guard let atom = try gjfToAtom(line: line, number: molecule.atoms.count + 1) else {continue}
            molecule.atoms.append(atom)
        }
        self.steps = [Step(molecule: molecule, isFinalStep: true)]
    }
    
    private func readgjfFile(fromlog: String) throws -> Step {
        var molecule = Molecule()
        for line in fromlog.components(separatedBy: "\n") {
            guard let atom = try gjfToAtom(line: line, number: molecule.atoms.count + 1) else {continue}
            molecule.atoms.append(atom)
        }
        return Step(molecule: molecule)
    }

    private func gjfToAtom(line: String, number: Int) throws -> Atom? {
        
        var atom: Atom?
        
        let fixedLine = line.replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\r", with: "")
        for atomName in Element.allCases {
            if fixedLine.contains("\(atomName.rawValue) ") {
                let lineComponents = fixedLine.split(separator: " ")
                print(lineComponents)
                guard let x = Float(lineComponents[1]), let y = Float(lineComponents[2]), let z = Float(lineComponents[3]) else {throw ReadingErrors.badInputCoords}
                #if os(macOS)
                let position = SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
                #else
                let position = SCNVector3(x: x, y: y, z: z)
                #endif
                atom = Atom(id: UUID(), position: position, type: atomName, number: number)
            }
        }
        return atom
    }
    
    private func restoreInputReader() {
        asteriscs =  0
        inputSeparators =  0
        titleSeparators = 0
        readInput = false
        readTitle = false
        readInputCoords = false
        readingKeywords = false
        readOldGeom = false
        didReadInput = false
    }
    
    // These are some of the important strings that appear on a Gaussian .log file. They can be used to track the output.
    private enum GaussianSeparators: String, CaseIterable {
        case standardOrientation = "                         Standard orientation:                         " // When writing the coordinates of each step, Gaussian writes them in a box with this title.
        case orientationSeparator = " ---------------------------------------------------------------------" // Then, there are three separators like this that encampsulate the coordinates.
        case inputKeywords1 = " ----------------------------------------------------------------------" // The keywords from the input file are locathed between two of those.
        case inputKeywords2 = " --------------------------------------------------"
        case asterisc = " ******************************************" // After two of these lines, the inputfile that was given to Gaussian is written back into the log file.
        case title = " ----------" // The title of the job is written between two of those.
        case title2 = " ------------"
    }
    
    enum ReadingErrors: Error, LocalizedError {
        case badInputCoords
        case internalFailure
        case badTermination
        case badFreqs
        case badEnergy
        case unknown
        
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
            case .unknown:
                return "Unknown error. Contact developer."
            }
        }
    }
    
}

