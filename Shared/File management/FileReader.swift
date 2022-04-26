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
    
    public func readFile(fileURL: URL, dataString: String) -> [Step]? {
        switch fileURL.pathExtension {
        case "gjf", "com":
            return readGJF(data: dataString)
        case "log", "qfi":
            return readLOG(data: dataString)
        default:
            return nil
        }
    }
    
    private func readLOG(data: String) -> [Step]? {
        var steps = [Step]()
        var molecule = Molecule()
        var energy: Double = 0
        var readCoords = false
        var previousLine = ""
        var previousLine2 = ""
        let lines = data.components(separatedBy: "\n")
        for line in lines {
//            if line.contains("Frequencies") {
//                var components = line.components(separatedBy: " ")
//                components = components.filter { $0 != "" }
//                let index = steps.count - 1
//                steps[index].frequencys.append(Double(components[2]) ?? 0)
//                steps[index].frequencys.append(Double(components[3]) ?? 0)
//                steps[index].frequencys.append(Double(components[4]) ?? 0)
//            }
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
        return steps
    }
    
    
    private func readGJF(data: String) -> [Step]? {
        var molecule = Molecule()
        let lines = data.components(separatedBy: "\n")
        for line in lines {
            if let atom = gjfToAtom(line: line, number: molecule.atoms.count + 1) {
                molecule.atoms.append(atom)
            }
        }
        return [Step(molecule: molecule, energy: 0)]
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




extension MolReader {
    private var separator: String {
        "-------------------------------------------------------------------"
    }
}

