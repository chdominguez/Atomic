// MolReader extension to load GAMESS and Gaussian LOG files.

import SceneKit

extension MolReader {
    
    func readLOG(data: String) -> [Step]? {
        let separatedData = data.components(separatedBy: "\n")
        var logSoftware: compSoftware = .gaussian
        
        //First check .log type. Gaussian or GAMESS
        for software in compSoftware.allCases {
            if separatedData[0].contains(software.rawValue) {
                logSoftware = software
            }
        }
        
        //Read specifically one of the softwares
        switch logSoftware {
        case .gaussian:
            guard let steps = readGaussianlog(lines: separatedData) else {return nil}
            return steps
        case .gamess:
            //guard let steps = readGAMESSlog(lines: separatedData) else {return nil}
            return nil
        }
        
    }
    
    //Read a Gaussian log file
    private func readGaussianlog(lines: [String]) -> [Step]? {
        
        var steps: [Step] = []
        var inputFile: String = ""
        var currentStep: Step = Step()
        
        var didReadInput: Bool = false
        var asteriscs: Int = 0
        var separators: Int = 0
        var startReadingInput: Bool = false
        var readTitle: Bool = false
        var readInputCoords: Bool = false
        var titleSeparators: Int = 0
        var oldForm: Bool = false
        
        var startReadingCoords: Bool = false
        var stepMolecule = Molecule()
        
        for line in lines {
            if !didReadInput {
                if line == asteriscsString {
                    asteriscs += 1
                }
                else if asteriscs == 2 {
                    startReadingInput = true
                    if line == separator {
                        separators += 1
                    }
                }
                if separators == 2 {
                    startReadingInput = false
                    asteriscs = 0
                    separators = 0
                }
                if startReadingInput {
                    if !line.contains("Will use") && !line.contains(separator) {
                        inputFile += line.dropFirst() + "\n"
                    }
                }
                if line == titleSeparator && titleSeparators == 0 {
                    titleSeparators += 1
                    readTitle = true
                }
                else if readTitle {
                    inputFile += "\n" + line.dropFirst() + "\n"
                    readTitle = false
                }
                if line.contains("Charge") {
                    let components = line.components(separatedBy: " ")
                    inputFile += "\n" + components[4] + " " + components[7] + "\n"
                    readInputCoords = true
                }
                else if readInputCoords {
                    if line == "\n" || line.contains("Recover") {
                        readInputCoords = false
                        didReadInput = true
                    }
                    else if line.contains("old form") {
                        oldForm = true
                    }
                    else if oldForm {
                        var separated = line.components(separatedBy: ",")
                        separated.remove(at: 1)
                        inputFile += separated.joined(separator: "  ").dropFirst() + "\n"
                    }
                    else {
                        inputFile += line.dropFirst()
                    }
                }
            }
            
            else {
                if line.contains("SCF Done:") {
                    var components = line.components(separatedBy: " ")
                    components = components.filter { $0 != "" }
                    let i = components.firstIndex(of: "=")!
                    currentStep.energy = Double(components[i + 1])!
                }
                if line.contains("Standard orientation") {
                    startReadingCoords = true
                }
                if startReadingCoords && line.contains(separator) && separators < 2 {
                    separators += 1
                }
                else if separators == 2 {
                    if line.contains(separator) {
                        
                        startReadingCoords = false
                        separators = 0
                        currentStep.molecule = stepMolecule
                        steps.append(currentStep)
                        
                        currentStep = Step()
                        stepMolecule = Molecule()
                    }
                    else if let atom = gausslogToAtom(line: line) {
                        stepMolecule.atoms.append(atom)
                    }
                }
            }
        }
        
        let inputStep = readGJF(data: inputFile)
        if let inputStep = inputStep {
            steps.insert(inputStep.first!, at: 0)
        }
        
        if steps.isEmpty {
            return nil
        }
        else {
            return steps
        }
    }
    private func gausslogToAtom(line: String) -> Atom? {
        
        print(line)
        
        var atom: Atom?
        
        var components = line.components(separatedBy: " ")
        components = components.filter { $0 != "" }
        let atomNumber = Int(components.first!) ?? 0
        
        for atomName in Element.allCases {
            if atomName.atomicNumber == Int(components[1]) {
                guard let x = Float(components[3]),
                      let y = Float(components[4]),
                      let z = Float(components[5])
                else {return nil}
                #if os(macOS)
                let position = SCNVector3(x: CGFloat(x), y: CGFloat(y), z: CGFloat(z))
                #else
                let position = SCNVector3(x: x, y: y, z: z)
                #endif
                atom = Atom(id: UUID(), position: position, type: atomName, number: atomNumber)
            }
        }
        
        guard let atom = atom else {return nil}
        return atom
    }
    
    //Read a GAMESS log file
    //private func readGAMESSlog(lines: [String]) -> [Step]? {
       //WIP
    //}
    
    private var asteriscsString: String {
        "******************************************"
    }
    
    private var separator: String {
        "-------------------------------------------------------------------"
    }
    
    private var titleSeparator: String {
        " ----------"
    }
}

//let lines = data.components(separatedBy: "\n")
//for line in lines {
//    if line.contains("Frequencies") {
//        var components = line.components(separatedBy: " ")
//        components = components.filter { $0 != "" }
//        let index = steps.count - 1
//        steps[index].frequencys.append(Double(components[2]) ?? 0)
//        steps[index].frequencys.append(Double(components[3]) ?? 0)
//        steps[index].frequencys.append(Double(components[4]) ?? 0)
//    }
//    if line.contains("SCF Done:") {
//        var components = line.components(separatedBy: " ")
//        components = components.filter { $0 != "" }
//        let i = components.firstIndex(of: "=")!
//        steps[steps.count - 1].energy = Double(components[i + 1])!
//    }
//    if line.contains(separator) && previousLine2.contains("Coordinates"){
//        readCoords = true
//    }
//    else if readCoords && !line.contains(separator) {
//        if let atom = logToAtom(line: line, number: molecule.atoms.count + 1) {
//            molecule.atoms.append(atom)
//        }
//    }
//    else {
//        if readCoords {
//            let step = Step(molecule: molecule, energy: energy, jobtype: .opt)
//            steps.append(step)
//            energy = 0
//            molecule.atoms.removeAll()
//        }
//        readCoords = false
//    }
//    previousLine2 = previousLine
//    previousLine = line
//}
//return steps
