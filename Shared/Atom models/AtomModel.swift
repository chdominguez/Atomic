//
//  AtomModel.swift
//  AtomModel
//
//  Created by Christian Dominguez on 20/8/21.
//

import Foundation
import SceneKit
import SwiftStride

struct Atom: Identifiable {
    let id = UUID()
    
    var position: SCNVector3
    var type: Element
    var number: Int
  
    var info: String = "" // Allows for further classification. For example: "CA", which denotes an alpha carbon in PDBs.
}

/// Molecule class. Contains an array of atoms as its single property
class Molecule {
    var atoms: [Atom] = []
}

struct CartoonPositions {
    var positions: [SCNVector3] = []
    var structure: SecondaryStructure = .alphaHelix
}

/// Step class. Describes any molecular scene possible. Contains different optional variables depending on which
/// type of file has been opened. It has support for accomodating multiple job types like:
/// Gaussian - energy, isFinalStep, jobNumber, isInput
/// XYZ - timestep
class Step {
    /// The step number of the job (for example in optimization calculations)
    var stepNumber: Int?
    
    /// The molecule of this step. Contains the atom positions.
    var molecule: Molecule?
    
    /// Keeping track if its a step from an input file
    var isInput: Bool?
    
    /// The energy of the system at this step
    var energy: Double?
    
    /// Atom vibrations calculation jobs
    var frequencys: [Double]?
    
    /// If the calculation ended with normal termination, set to true to the last step.
    var isFinalStep: Bool = false
    
    /// For packages that support multiple jobs on the same calculation i.e Gaussian's --link1--
    var jobNumber: Int = 1
    
    /// For MD calculations, the time of this step.
    var timestep: Int?
    
    /// For PDBs. Tells the renderer if the step contains a protein
    var isProtein: Bool = false
    
    /// For PDBs. Rendering the backbone only implies rendering these atoms
    var backBone: Molecule?
    
    /// Residues present in this step
    var res: [Residue]? = nil
}

struct Frequencies {
    var freq: Double?
    var infrared: Double?
    var raman: Double?
}

#warning("TODO: Implement different bond types")
enum bondTypes {
    case single
    case double
    case triple
    case resonant
}

enum AtomStyle: String, CaseIterable {
    case ballAndStick = "Ball and Stick"
    case backBone = "Backbone"
    case cartoon = "Cartoon"
}
