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

struct Molecule {
    var atoms = [Atom]()
}

struct Step {
    var molecule: Molecule
    var energy: Double = 0
    var frequencys = [Double]()
}
