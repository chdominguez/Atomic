//
//  ToolsController.swift
//  Atomic
//
//  Created by Christian Dominguez on 24/11/21.
//

import Foundation


class ToolsController: ObservableObject {
    
    static let shared = ToolsController()
    
    @Published var selectedTool: mainTools = .selectAtom
    
    enum mainTools {
        case addAtom
        case removeAtom
        case selectAtom
    }
    
}
