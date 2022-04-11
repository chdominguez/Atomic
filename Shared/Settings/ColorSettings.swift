//
//  ColorSettings.swift
//  Atomic
//
//  Created by Christian Dominguez on 11/4/22.
//
import SceneKit
import SwiftUI


class ColorSettings: ObservableObject {
    
    #warning("TODO: Auto update color changes")
    
    static let shared = ColorSettings()
    
    @Published var backgroundColor: Color = .white
    @Published var bondColor: Color = .gray
    
    @Published var atomColors: [Color] = []
    
    init() {
        for atom in Element.allCases {
            atomColors.append(atom.color)
        }
    }
}

