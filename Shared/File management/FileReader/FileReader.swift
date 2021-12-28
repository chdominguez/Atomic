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
}

extension MolReader {    
    //Recognized computational software
    enum compSoftware: String, CaseIterable {
        case gaussian = "Entering Gaussian System"
        case gamess = "GAMESS"
    }
}

