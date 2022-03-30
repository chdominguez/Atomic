//
//  FileReader.swift
//  FileReader
//
//  Created by Christian Dominguez on 20/8/21.
//

import Foundation
import UniformTypeIdentifiers


//final class MolReader {
//
//    func readFile(fileURL: URL, dataString: String) throws -> [Step]? {
//
//    }
//
    #warning("TODO: Reading LOGS is disabled momentarely")
////    private func readLOG(data: String) throws -> GaussianReader {
////
////        // Check from what software the log file came from
////        var logFrom: logSoftware? = nil
////
////        //First check Gaussian or GAMESS
////        for software in logSoftware.allCases {
////            if data.contains(software.rawValue) {
////                logFrom = software
////            }
////        }
////
////        guard let logFrom = logFrom else {throw SoftwareErrors.unrecognized}
////
////        //Read specifically one of the softwares
////        switch logFrom {
////        case .gaussian:
////            let gReader = GaussianReader(file: data)
////            try gReader.getStepsFromLog()
////            WindowManager.shared.currentController?.BR = gReader
////
////            return gReader
////        case .gamess:
////            //guard let steps = readGAMESSlog(lines: separatedData) else {return nil}
////            throw ReadingErrors.internalFailure
////        }
////
////    }
//
//    //Recognized computational software
//    private enum logSoftware: String, CaseIterable {
//        case gaussian = "Entering Gaussian System"
//        case gamess = "GAMESS"
//    }
//
//    private enum SoftwareErrors: Error, LocalizedError {
//        case unrecognized
//
//        public var errorDescription: String? {
//            switch self {
//            case .unrecognized:
//                return "Unrecognized file type"
//            }
//        }
//    }
//
//}

/// Main class that processed files to be read and transformed into [Step] for teh visualizer to work. Each file type has his own function. Support for new files can be added extending the class.
class BaseReader {
    
    // The url of the opened file
    internal let fileURL: URL
    
    // Keep trak the reading line in case of failure
    internal var errorLine = 0
    
    // Output file saved in an array for each line
    internal let openedFile: [String]
    
    // The read steps from the opened file
    public var steps: [Step] = []
    
    /// Initialize the base reader class with the opened file as an string using the file url
    /// - Parameter fileAsString: The contents of the file as a unique string
    init(fileURL: URL) throws {
        self.fileURL = fileURL
        self.openedFile = (try String(contentsOf: fileURL)).components(separatedBy: "\n")
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
        
        #warning ("TODO Implement each of the allowed files")
        switch FE {
        case .pdb:
            try readPDBSteps()
        case .xyz:
            try readXYZSteps()
        case .gjf, .com:
            try readGJFSteps()
        case .log, .qfi:
            #warning("TODO: Fix Job did not terminate")
            try readGaussianLogSteps()
        case .none:
            throw ReadingErrors.notImplemented
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

//final class MolReader {
//
//    func readFile(fileURL: URL, dataString: String) throws -> [Step]? {
//
//    }
//
//    ///TO DO: Reading LOGS is disabled momentarely
////    private func readLOG(data: String) throws -> GaussianReader {
////
////        // Check from what software the log file came from
////        var logFrom: logSoftware? = nil
////
////        //First check Gaussian or GAMESS
////        for software in logSoftware.allCases {
////            if data.contains(software.rawValue) {
////                logFrom = software
////            }
////        }
////
////        guard let logFrom = logFrom else {throw SoftwareErrors.unrecognized}
////
////        //Read specifically one of the softwares
////        switch logFrom {
////        case .gaussian:
////            let gReader = GaussianReader(file: data)
////            try gReader.getStepsFromLog()
////            WindowManager.shared.currentController?.BR = gReader
////
////            return gReader
////        case .gamess:
////            //guard let steps = readGAMESSlog(lines: separatedData) else {return nil}
////            throw ReadingErrors.internalFailure
////        }
////
////    }
//
//    //Recognized computational software
//    private enum logSoftware: String, CaseIterable {
//        case gaussian = "Entering Gaussian System"
//        case gamess = "GAMESS"
//    }
//
//    private enum SoftwareErrors: Error, LocalizedError {
//        case unrecognized
//
//        public var errorDescription: String? {
//            switch self {
//            case .unrecognized:
//                return "Unrecognized file type"
//            }
//        }
//    }
//
//}
