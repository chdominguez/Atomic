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
    
    func readFile(fileURL: URL, dataString: String) throws -> [Step]? {
        switch fileURL.pathExtension {
        case "pdb":
            let pdbReader = PDBreader(file: dataString)
            let steps = try pdbReader.getSteps()
            return steps
        case "xyz":
            let xyzReader = XYZReader(file: dataString)
            let steps = try xyzReader.getSteps()
            return steps
        case "gjf", "com":
            let gReader = GaussianReader(file: dataString)
            try gReader.getStepsFromGJF()
            
            /// TO DO: Check bugs when returning only the steps and not the reader
            return gReader.steps
        case "log", "qfi":
            let gReader = try readLOG(data: dataString)
            return gReader.steps
        default:
            return nil
        }
    }
    
    private func readLOG(data: String) throws -> GaussianReader {
        
        // Check from what software the log file came from
        var logFrom: logSoftware? = nil
        
        //First check Gaussian or GAMESS
        for software in logSoftware.allCases {
            if data.contains(software.rawValue) {
                logFrom = software
            }
        }
        
        guard let logFrom = logFrom else {throw SoftwareErrors.unrecognized}
        
        //Read specifically one of the softwares
        switch logFrom {
        case .gaussian:
            let gReader = GaussianReader(file: data)
            try gReader.getStepsFromLog()
            WindowManager.shared.currentController?.gReader = gReader
            
            return gReader
        case .gamess:
            //guard let steps = readGAMESSlog(lines: separatedData) else {return nil}
            throw ReadingErrors.internalFailure
        }
        
    }
    
    //Recognized computational software
    private enum logSoftware: String, CaseIterable {
        case gaussian = "Entering Gaussian System"
        case gamess = "GAMESS"
    }
    
    private enum SoftwareErrors: Error, LocalizedError {
        case unrecognized
        
        public var errorDescription: String? {
            switch self {
            case .unrecognized:
                return "Unrecognized file type"
            }
        }
    }
    
}

