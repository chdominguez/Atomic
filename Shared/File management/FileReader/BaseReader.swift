//
//  FileReader.swift
//  FileReader
//
//  Created by Christian Dominguez on 20/8/21.
//

import Foundation
import UniformTypeIdentifiers

/// Main class that processed files to be read and transformed into [Step] for teh visualizer to work. Each file type has his own function. Support for new files can be added extending the class.
class BaseReader {
    
    // The url of the opened file
    internal let fileURL: URL
    
    // Keep trak the reading line in case of failure
    internal var errorLine = 0
    
    // Output file saved in an array for each line
    internal let splitFile: [String]
    
    // The read steps from the opened file
    public var steps: [Step] = []
    
    /// Initialize the base reader class with the opened file as an string using the file url
    /// - Parameter fileAsString: The contents of the file as a unique string
    init(fileURL: URL) throws {
        self.fileURL = fileURL
        self.splitFile = (try String(contentsOf: fileURL)).components(separatedBy: "\n")
    }
    
    /// Returns the Element of the given String with an atomic symbol or the atomic number
    /// - Parameter string: String containing atomic symbol or number (i.e 'H' or '1' for Hydrogen)
    /// - Returns: Element matching atomic symbol or number
    internal func getAtom(fromString string: String) -> Element? {
        if let atomicNumber = Int(string) {
            return Element.allCases[atomicNumber - 1]
        } else {
            return Element.allCases.first(where: {$0.rawValue == string.prefix(1)})
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
        
        // For eveyr allowed file extension, a reader function is assigned.
        switch FE {
        case .pdb:
            try readPDBSteps()
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
