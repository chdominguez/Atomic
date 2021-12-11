//
//  FileReader.swift
//  FileReader
//
//  Created by Christian Dominguez on 20/8/21.
//

import Foundation
import SceneKit
import SwiftUI


final class MolReader {
    
    public func readFile(_ file: URL) -> [Step]? {
        switch file.pathExtension {
        case "gjf":
            return readGJF(fileURL: file)
        case "log", "qfi":
            return readLOG(fileURL: file)
        default:
            return nil
        }
    }
    
    private func readLOG(fileURL: URL) -> [Step]? {
        var steps = [Step]()
        var molecule = Molecule()
        var energy: Double = 0
        var readCoords = false
        var previousLine = ""
        var previousLine2 = ""
        do {
            if fileURL.startAccessingSecurityScopedResource() {
                let textContent = try String(contentsOf: fileURL)
                let lines = textContent.components(separatedBy: "\n")
                for line in lines {
                    if line.contains("Frequencies") {
                        var components = line.components(separatedBy: " ")
                        components = components.filter { $0 != "" }
                        let index = steps.count - 1
                        steps[index].frequencys.append(Double(components[2]) ?? 0)
                        steps[index].frequencys.append(Double(components[3]) ?? 0)
                        steps[index].frequencys.append(Double(components[4]) ?? 0)
                    }
                    if line.contains("SCF Done:") {
                        var components = line.components(separatedBy: " ")
                        components = components.filter { $0 != "" }
                        let i = components.firstIndex(of: "=")!
                        steps[steps.count - 1].energy = Double(components[i + 1])!
                    }
                    if line.contains(separator) && previousLine2.contains("Coordinates"){
                        readCoords = true
                    }
                    else if readCoords && !line.contains(separator) {
                        if let atom = logToAtom(line: line, number: molecule.atoms.count + 1) {
                            molecule.atoms.append(atom)
                        }
                    }
                    else {
                        if readCoords {
                            let step = Step(molecule: molecule, energy: energy)
                            steps.append(step)
                            energy = 0
                            molecule.atoms.removeAll()
                        }
                        readCoords = false
                    }
                    previousLine2 = previousLine
                    previousLine = line
                }
            }
            fileURL.stopAccessingSecurityScopedResource()
            return steps
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
   private func readGJF(fileURL: URL) -> [Step]? {
        var molecule = Molecule()
        do {
            if fileURL.startAccessingSecurityScopedResource() {
                let textContent = try String(contentsOf: fileURL)
                let lines = textContent.components(separatedBy: "\n")
                for line in lines {
                    if let atom = gjfToAtom(line: line, number: molecule.atoms.count + 1) {
                        molecule.atoms.append(atom)
                    }
                }
            }
            fileURL.stopAccessingSecurityScopedResource()
            return [Step(molecule: molecule, energy: 0)]
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func logToAtom(line: String, number: Int) -> Atom? {
        
        var atom: Atom?
        
        var components = line.components(separatedBy: " ")
        components = components.filter { $0 != "" }
        
        for atomName in Element.allCases {
            if atomName.atomicNumber == Int(components[1]) {
                guard let x = Float(components[3]),
                      let y = Float(components[4]),
                      let z = Float(components[5])
                else {return nil}
                let position = SCNVector3(x: x, y: y, z: z)
                atom = Atom(id: UUID(), position: position, type: atomName, number: number)
            }
        }
        
        guard let atom = atom else {return nil}
        return atom
    }
    
    private func gjfToAtom(line: String, number: Int) -> Atom? {
        
        var atom: Atom?
        
        for atomName in Element.allCases {
            if line.contains("\(atomName.rawValue) ") {
                var lineComponents = line.components(separatedBy: " ")
                lineComponents = lineComponents.filter { $0 != "" }
                lineComponents = lineComponents.filter { $0 != atomName.rawValue }
                guard let x = Float(lineComponents[0]), let y = Float(lineComponents[1]), let z = Float(lineComponents[2]) else {return nil}
                    let position = SCNVector3(x: x, y: y, z: z)
                atom = Atom(id: UUID(), position: position, type: atomName, number: number)
                }
            }
        guard let atom = atom else {return nil}
        return atom
        }

}


extension MolReader {
    private var separator: String {
        "-------------------------------------------------------------------"
    }
    
    static func demoReader(demoFile: String) -> [Step] {
        var molecule = Molecule()
        let lines = demoFile.components(separatedBy: "\n")
        for line in lines {
            if let atom = demoGJFToAtom(line: line, number: molecule.atoms.count + 1) {
                molecule.atoms.append(atom)
            }
        }
        return [Step(molecule: molecule)]
    }
    
    static private func demoGJFToAtom(line: String, number: Int) -> Atom? {
        
        var atom: Atom?
        
        for atomName in Element.allCases {
            if line.contains("\(atomName.rawValue) ") {
                var lineComponents = line.components(separatedBy: " ")
                lineComponents = lineComponents.filter { $0 != "" }
                lineComponents = lineComponents.filter { $0 != atomName.rawValue }
                guard let x = Float(lineComponents[0]), let y = Float(lineComponents[1]), let z = Float(lineComponents[2]) else {return nil}
                    let position = SCNVector3(x: x, y: y, z: z)
                atom = Atom(id: UUID(), position: position, type: atomName, number: number)
                }
            }
        guard let atom = atom else {return nil}
        return atom
        }
    
    static var demoMoleculeObject: Molecule {
        demoReader(demoFile: demoGJF)[0].molecule
    }
    
    static var demoGJF: String { """
    %nprocs=32
    %chk=/users/cdominguez/checks/react-abs1w33.chk
    %mem=15GB
    #p opt def2tzvp iop(3/76=0560004400) umpwb95

    Abstraccio W33 H+H3CS -> H2 + H2CS(1/3)

    0 3
    O                  0.15045200   -2.56308900   -3.35900900
    H                  0.94947200   -2.03316800   -3.38136400
    H                  0.47097700   -4.01339800   -2.19502000
    O                  6.64490900   -1.20188200   -1.03761900
    O                  3.56318900    1.84379000    1.41173900
    H                  5.40086800   -2.03837300   -1.76876600
    H                  6.81953500   -1.35985600   -0.10234700
    H                  2.70268900    1.44674500    1.22147700
    H                  3.90981000    2.13485000    0.56081800
    O                  1.41403500    0.30249500    0.51947300
    O                  4.69657300   -2.57268900   -2.19825700
    H                 -0.52206800   -2.05038300   -2.90382000
    H                  1.69838100   -0.52925600    0.94249100
    H                  5.13052200   -3.33241200   -2.57412100
    H                  3.44865800   -1.73599600   -3.10659500
    O                  2.74477600   -1.22795400   -3.54788200
    H                  2.47716300    0.30835000   -2.56676100
    H                  2.98347400   -1.17353500   -4.46770100
    O                  0.53338700   -4.60542400   -1.43480500
    H                  1.37165000   -4.38892200   -0.99969300
    H                 -0.82635400   -4.21797800   -0.57405900
    O                  2.89073100   -3.78596100   -0.21409000
    H                  2.73135600   -3.17055100    0.51109300
    H                  3.50547000   -3.35073600   -0.80692100
    O                  2.37580700    1.04390600   -1.95099400
    H                  3.71266800    1.98117300   -1.59238100
    H                  2.01226700    0.67225900   -1.13126300
    O                  2.32682100   -1.90823100    1.82873600
    H                  3.10251700   -1.55840500    2.29378000
    H                  1.70173100   -2.24825500    2.48748300
    O                  6.93906300    1.65409700   -1.04447800
    H                  7.52604100    2.09102300   -1.65309100
    H                  6.76984900   -0.25588800   -1.16097700
    O                  5.51369900    2.27861400    3.43937500
    H                  4.74379800    2.36332400    2.86920900
    H                  5.35225700    1.46507900    3.91394000
    O                  7.12327200   -1.19782900    1.74640900
    H                  7.41032600   -0.25912100    1.81153200
    H                  7.77039200   -1.72729300    2.20035700
    O                  7.59781400    1.39844800    1.75866300
    H                  6.94789300    1.83520500    2.32728100
    H                  7.41633900    1.66787700    0.85443200
    O                  4.40178900    2.57192300   -1.21207800
    H                  6.05404200    2.03724900   -1.17774600
    H                  4.15297500    3.46736400   -1.43963600
    O                  4.53356500   -0.54354100    2.72757900
    H                  5.38158700   -0.89911900    2.43979400
    H                  4.36407000    0.22675800    2.17561800
    H                  0.44668700    0.28448400    0.52368600
    O                  0.35454200   -2.87327600    3.50397100
    H                  0.36803700   -3.81523800    3.63912800
    O                 -1.66272500   -3.85843800   -0.19536400
    H                 -1.75899400   -2.90757300    1.21101200
    H                 -2.34448000   -4.54653700   -0.24533200
    O                 -5.88703300    0.14773100    2.43838200
    O                 -3.89841400    2.98782300   -1.59704500
    H                 -5.44470900   -0.70715700    2.35942000
    H                 -6.50624200    0.23677800    1.70657800
    H                 -3.24231700    2.95695000   -2.28674500
    H                 -3.43018000    2.85026400   -0.75740300
    O                 -2.00473200   -1.56218700   -1.64266700
    O                 -4.59482700   -2.31439300    2.21604100
    H                 -1.95424400   -2.42014600   -1.18202900
    H                 -2.90160300   -1.50769000   -1.99564500
    H                 -4.82688600   -2.96010500    2.87676700
    H                 -3.61705300   -2.30335500    2.17310900
    O                 -1.90069500   -2.27343200    1.94519100
    H                 -1.69346800   -1.40736600    1.56684500
    H                 -0.48031600   -2.67852300    3.05484700
    O                 -3.85906100   -5.49479700   -0.22196100
    H                 -4.53585900   -4.80581200   -0.33710300
    H                 -4.04776700   -6.18270300   -0.85024700
    O                 -5.49928500   -3.32864200   -0.34172000
    H                 -5.27561600   -2.70232900   -1.03714500
    H                 -5.26074700   -2.91102800    0.49081000
    O                 -1.35097300    0.05006800    0.44701900
    H                 -1.88874600    0.83949000    0.55382100
    H                 -1.62007100   -0.39846200   -0.37636100
    O                 -4.71819000   -1.48261400   -2.40985400
    H                 -5.15116100   -0.61591000   -2.25596600
    H                 -4.96661700   -1.75839900   -3.28653100
    O                 -4.66091600    2.42345900    2.70154500
    H                 -4.51989800    2.61326400    3.62380900
    H                 -5.08154900    1.52714900    2.65548200
    O                 -5.70800000    5.02430100   -0.89025600
    H                 -5.08430300    4.41608600   -1.30149300
    H                 -6.21584800    5.41879200   -1.59107500
    O                 -7.51186900    1.08870600    0.31989400
    H                 -7.37213300    2.01748300    0.60893400
    H                 -8.45186800    0.94437200    0.28177400
    O                 -6.86201100    3.51824300    1.15884300
    H                 -6.52799500    4.12256700    0.48321200
    H                 -6.14193600    3.37430400    1.77742300
    O                 -2.70961500    2.55323100    0.85452600
    H                 -3.38681500    2.51436800    1.56057100
    H                 -2.05098300    3.17480500    1.15087800
    O                 -5.85727200    0.87317600   -1.95171800
    H                 -6.48445200    0.91130000   -1.21906600
    H                 -5.24743800    1.60506900   -1.83070000
    S                  2.48365100    5.28988000   -1.70803800
    C                  1.41548700    4.16319000   -0.88950300
    H                  1.38173600    3.24529000   -1.47935600
    H                  1.86615100    3.88372500    0.06961200
    H                 -2.60771700    6.17662800   -0.11890800
    H                  0.29523400    4.71827900   -0.69875300

"""}
    
}

