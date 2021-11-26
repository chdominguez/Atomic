//
//  ToolsController.swift
//  Atomic
//
//  Created by Christian Dominguez on 24/11/21.
//

import Foundation


class ToolsController: ObservableObject {
    
    static let shared = ToolsController()
    
    @Published var selected1Tool: level1Tools = .manipulate
    @Published var selected2Tool: level2Tools = .selectAtom
    
}
