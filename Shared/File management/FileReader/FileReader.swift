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
    
    
    func readGJF(data: String) -> [Step]? {
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

    
}


extension MolReader {    
    //Recognized computational software
    enum compSoftware: String, CaseIterable {
        case gaussian = "Entering Gaussian System"
        case gamess = "GAMESS"
    }
}

