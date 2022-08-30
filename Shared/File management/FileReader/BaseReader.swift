//
//  FileReader.swift
//  FileReader
//
//  Created by Christian Dominguez on 20/8/21.
//

import ProteinKit
import UniformTypeIdentifiers
import SwiftUI

/// Main class that processed files to be read and transformed into [Step] for teh visualizer to work. Each file type has his own function. Support for new files can be added extending the class.
class BaseReader: ObservableObject {
    
    // The url of the opened file
    internal let fileURL: URL
    
    // Keep trak the reading line in case of failure
    internal var errorLine = 0
    
    // Output file saved in an array for each line
    @Published var splitFile: [String.SubSequence]? = nil
    
    // The read steps from the opened file
    public var steps: [Step] = []
    
    // Progress while reading file
    @Published var progress: Double = 0
    var progressEvery: Int {
        return (splitFile!.count / 10) == 0 ? 1 : splitFile!.count / 10
    }
    
    /// Initialize the base reader class with the opened file as an string using the file url
    /// - Parameter fileAsString: The contents of the file as a unique string
    init(fileURL: URL) throws {
        self.fileURL = fileURL
    }
    
    /// Returns the Element of the given String with an atomic symbol or the atomic number
    /// - Parameter string: String containing atomic symbol or number (i.e 'H' or '1' for Hydrogen)
    /// - Returns: Element matching atomic symbol or number
    internal func getAtom(fromString string: String, isPDB: Bool = false) -> Element? {
        if isPDB {
            return Element.allCases.first(where: {$0.rawValue == string.prefix(1)})
        }
        else {
            if let atomicNumber = Int(string) {
                return Element.allCases[atomicNumber - 1]
            } else {
                return Element.allCases.first(where: {$0.rawValue == string})
            }
        }
    }
    
    /// Main function used to read the steps. Then, they can be retrieved from the property.
    public func readSteps() throws {
        
        // Assign the File Extension for cleaner code to the allowed file extension enum
        var FE: AFE? = nil
        for fe in AFE.allCases {
            if fileURL.pathExtension == fe.rawValue {
                FE = fe
                break
            }
        }
        
        if FE != .pdb {
            DispatchQueue.global(qos: .userInitiated).sync {
                let splitted = try! String(contentsOf: self.fileURL).split(separator: "\n")
                DispatchQueue.main.sync {
                    self.splitFile = splitted
                }
            }
        }
        
        // For every allowed file extension, a reader function is assigned.
        switch FE {
        case .pdb:
            let p = PDBReader()
            try p.readPDB(from: fileURL)
            self.steps = p.steps
        case .xyz:
            try readXYZSteps()
        case .gjf, .com:
            try readGJFSteps()
        case .log, .qfi:
            try readGaussianLogSteps()
        case .none:
            throw AtomicErrors.notImplemented
        }
        
    }
    
    func increaseProgress() {
        if errorLine % self.progressEvery == 0 {
            DispatchQueue.main.sync {
                progress += 0.1
            }
        }
    }
    
}

/// Allowed File Extensions (A.F.E.) that can be opened with Atomic.
/// Make changes in order to implement a new file type
enum AFE: String, CaseIterable {
    case pdb = "pdb"
    case xyz = "xyz"
    case gjf = "gjf"
    case com = "com"
    case log = "log"
    case qfi = "qfi"
}

/// Atomic errors for handling file reading, scene setup...
enum AtomicErrors: Error, LocalizedError {
    
    // Gaussian Errors
    case badInputCoords
    case badTermination
    case gaussLogError
    
    // XYZ errors
    case xyzError
    
    // PDB errors
    case pdbError
    
    // Misc
    case unknown
    case internalFailure
    case notImplemented
    
    // Error description for each case error
    public var errorDescription: String? {
        switch self {
        case .badInputCoords:
            return "Input coordinates are wrong"
        case .internalFailure:
            return "Internal failure"
        case .badTermination:
            return "Bad termination"
        case .gaussLogError:
            return "Error in Gaussian output"
        
        case .xyzError:
            return "Error in xyz"
            
        case .pdbError:
            return "Error in pdb"
            
        case .unknown:
            return "Unknown error. Contact developer."
        case .notImplemented:
            return "File type not implemented yet!"
        }
    }
}
