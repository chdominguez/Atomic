//
//  ColorSettings.swift
//  Atomic
//
//  Created by Christian Dominguez on 11/4/22.
//
import SceneKit
import SwiftUI


class GlobalSettings: ObservableObject {
    
    #warning("TODO: Auto update color changes")
    
    static let shared = GlobalSettings()
    
    
    @Published var backgroundColor: Color = .white
    
    @Published var bondColor: Color = .gray
    
    #warning("TODO: Change dynamically present atoms")
    @Published var atomColors: [Color] = []
    
    @Published var atomStyle: AtomStyle = .ballAndStick
    
    init() {
        for atom in Element.allCases {
            atomColors.append(atom.color)
        }
    }
}

