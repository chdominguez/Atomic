//
//  ErrorManager.swift
//  Atomic
//
//  Created by Christian Dominguez on 30/12/21.
//

import Foundation

class ErrorManager {
    
    static let shared = ErrorManager()
    
    var errorType: Error?
    var errorDescription: String?
    var lineError: Int = 0
    
}
