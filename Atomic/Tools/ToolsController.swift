//
//  ToolsController.swift
//  Atomic
//
//  Created by Christian Dominguez on 24/11/21.
//

import Foundation


class ToolsController: ObservableObject {
    
    static let shared = ToolsController()
    
    @Published var selected1Tool: mainTools = .manipulate
    @Published var selected2Tool: editTools = .selectAtom
    
}
