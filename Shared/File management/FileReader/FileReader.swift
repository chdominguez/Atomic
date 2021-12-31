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
    
    public func readFile(fileURL: URL, dataString: String) throws -> [Step]? {
        switch fileURL.pathExtension {
        case "gjf", "com":
            let gReader = GaussianReader(file: dataString)
            let steps = try gReader.getStepsFromGJF()
            return steps
        case "log", "qfi":
            return try readLOG(data: dataString)
        default:
            return nil
        }
    }
    
    func readLOG(data: String) throws -> [Step]? {
        
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
            let steps = try gReader.getStepsFromLog()
            MoleculeViewModel.shared.gReader = gReader
            return steps
        case .gamess:
            //guard let steps = readGAMESSlog(lines: separatedData) else {return nil}
            return nil
        }
        
    }
    
    //Recognized computational software
    enum logSoftware: String, CaseIterable {
        case gaussian = "Entering Gaussian System"
        case gamess = "GAMESS"
    }
    
    enum SoftwareErrors: Error, LocalizedError {
        case unrecognized
        
        public var errorDescription: String? {
            switch self {
            case .unrecognized:
                return "Unrecognized file type"
            }
        }
    }
    
}

