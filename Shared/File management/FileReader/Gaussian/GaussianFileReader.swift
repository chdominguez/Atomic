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
    typealias GS = GaussianSeparators
    
    // The file as a string array separated by lines
    let fileInput: [String]
    
    // Variables for reading the input Gaussian file located inside the log file
    var asteriscs:       Int =  0
    var inputSeparators: Int =  0
    var titleSeparators: Int =  0
    var readInput:       Bool = false
    var readTitle:       Bool = false
    var readInputCoords: Bool = false
    var readingKeywords: Bool = false
    var readOldGeom:     Bool = false
    var didReadInput:    Bool = false
    // The resulting input file written as a GJF file
    var inputFile = ""
    
    
    // Variables for reading the output file
    var orientSeparators: Int  = 0
    var orientCoords:     Bool = false
    var startStep:        Bool = false
    var inputOrientation: Bool = false
    
    // All of the steps in the output file are saved in an array of Step objects.
    var steps: [Step] = []
    var currentMolecule = Molecule()
    // The current step that is going to be appended
    var currentStep: Step = Step()
    
    // Error handling
    var readError: ReadingErrors? = nil
    var errorLine: Int? = nil
    
    // Initialize the class with the input file
    init(file: String) {
        self.fileInput = file.components(separatedBy: "\n")
    }
    
    public func getSteps() -> [Step]? {
        do {
            try readFile()
            return steps
        }
        catch let error as ReadingErrors {
            readError = error
            return nil
        }
        catch {
            readError = .unknown
            print("*** Unknown error")
            return nil
        }
    }
    
    private func readFile() throws {
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
        case GS.inputOrientation.rawValue:
            inputOrientation = true
        case GS.orientationSeparator.rawValue:
            orientSeparators += 1
            if orientSeparators == 2 {orientCoords = true}
            if orientSeparators == 3 {
                orientCoords = false
                orientSeparators = 0
                currentStep.molecule = currentMolecule
                currentMolecule = Molecule()
            }
        default:
            if orientCoords {
                let atom = try gaussInputOrientationToAtom(line)
                currentMolecule.atoms.append(atom)
            } else if line.contains("Frequencies") {
                //WIP Continue tomorrow
            }
        }
    }
    
    private func readInput(_ line: String) throws {
        switch line {
        case GS.asterisc.rawValue:
            asteriscs += 1
            if asteriscs == 2 {
                readInput = true
            }
        case GS.inputKeywords.rawValue:
            inputSeparators += 1
            readingKeywords = true
            if inputSeparators == 2 {
                readInput = false
                readingKeywords = false
                inputFile += "\n"
            }
        case GS.title.rawValue:
            readInput.toggle()
            inputFile += "\n"
        default:
            if line.contains("matrix") || line.contains("Will") {break}
            if line.contains("old form") {
                readOldGeom = true
                break
            }
            if line.contains("Charge") {
                let splitted = line.split(separator: " ")
                inputFile += splitted[2] + " " + splitted[5] + "\n"
                readInput = true
                break
            }
            if readInput {
                if line.contains("") || line.contains("Recover connectivity data from disk.") {
                    didReadInput = true
                    break
                }
                if readingKeywords {
                    inputFile += line.dropFirst()
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
        
        let components = line.components(separatedBy: " ").filter { $0 != "" }
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
    
    private func readGJF(data: String) -> [Step]? {
        var molecule = Molecule()
        let lines = data.components(separatedBy: "\n")
        for line in lines {
            if let atom = gjfToAtom(line: line, number: molecule.atoms.count + 1) {
                molecule.atoms.append(atom)
            }
        }
        return [Step(molecule: molecule)]
    }

    private func gjfToAtom(line: String, number: Int) -> Atom? {
        
        var atom: Atom?
        
        for atomName in Element.allCases {
            if line.contains("\(atomName.rawValue) ") {
                var lineComponents = line.components(separatedBy: " ")
                lineComponents = lineComponents.filter { $0 != "" }
                lineComponents = lineComponents.filter { $0 != atomName.rawValue }
                guard let x = Float(lineComponents[0]), let y = Float(lineComponents[1]), let z = Float(lineComponents[2]) else {return nil}
                #if os(macOS)
                let position = SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
                #else
                let position = SCNVector3(x: x, y: y, z: z)
                #endif
                atom = Atom(id: UUID(), position: position, type: atomName, number: number)
            }
        }
        guard let atom = atom else {return nil}
        return atom
    }
    
    enum GaussianSeparators: String, CaseIterable {
        case inputOrientation = "                          Input orientation   :                       "
        case orientationSeparator = " ---------------------------------------------------------------------"
        case inputKeywords = " ----------------------------------------------------"
        case asterisc = " ******************************************"
        case title = " ----------"
    }
    
    enum ReadingErrors: Error {
        case badInputCoords
        case unknown
    }
}

