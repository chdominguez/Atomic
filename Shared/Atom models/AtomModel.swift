//
//  AtomModel.swift
//  AtomModel
//
//  Created by Christian Dominguez on 20/8/21.
//

import Foundation
import SceneKit

struct Atom: Identifiable {
    let id = UUID()
    
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

/// Step struct. Describes any molecular scene possible. Contains different optional variables depending on which
/// type of file has been opened. It has support for accomodating multiple job types like:
/// Gaussian - energy, isFinalStep, jobNumber, isInput
/// XYZ - timestep
struct Step {
    
    // The step number of the job (for example in optimization calculations)
    var stepNumber: Int?
    
    // The molecule of this step. Contains the atom positions.
    var molecule: Molecule?
    
    // Keeping track if its a step from an input file
    var isInput: Bool?
    
    /// TO DO: Change this variable to another struct or class. Here does not make any sense
    // If the reading process is able to determine the  input file that produced such output, its saved in this variable
    var inputFile: String?
    
    // The energy of the system at this step
    var energy: Double?
    
    // Atom vibrations calculation jobs
    var frequencys: [Double]?
    
    // If the calculation ended with normal termination, set to true to the last step.
    var isFinalStep: Bool = false
    
    // For packages that support multiple jobs on the same calculation i.e Gaussian's --link1--
    var jobNumber: Int = 1
    
    // For MD calculations, the time of this step.
    var timestep: Int?
}

struct Frequencies {
    var freq: Double?
    var infrared: Double?
    var raman: Double?
}

enum bondTypes {
    case single
    case double
    case triple
    case resonant
}

