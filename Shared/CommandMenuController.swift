//
//  CommandMenuController.swift
//  Atomic
//
//  Created by Christian Dominguez on 31/12/21.
//

import Foundation
import SceneKit

class CommandMenuController: ObservableObject {
    
    static let shared = CommandMenuController()
    
    @Published var hasfreq: Bool = false
    @Published var inputLoaded: Bool = false
    
    @Published var currentScene: SCNScene? = nil
    
}