//
//  AtomModel.swift
//  AtomModel
//
//  Created by Christian Dominguez on 20/8/21.
//

import Foundation
import SceneKit

struct Atom: Identifiable {
    let id: UUID
    
    var position: SCNVector3
    var type: Element
    var number: Int
}

struct Bond {
    var pos1: SCNVector3
    var pos2: SCNVector3
    
    var type: bondTypes = .single
}

struct Molecule {
    var atoms = [Atom]()
    var bonds = [Bond]()
}

struct Step {
    var stepNumber: Int?
    var molecule: Molecule?
    var isInput: Bool?
    var inputFile: String?
    var energy: Double?
    var frequencys: [Double]?
    var isFinalStep: Bool = false
}

enum bondTypes {
    case single
    case double
    case triple
    case resonant
}

