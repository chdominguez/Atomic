//
//  ColorSettings.swift
//  Atomic
//
//  Created by Christian Dominguez on 11/4/22.
//
import ProteinKit
import SwiftUI


class GlobalSettings: ObservableObject {
    
    static let shared = GlobalSettings()
    
    @Published var colorSettings = ProteinColors()
    
    @Published var atomStyle: AtomStyle = .ballAndStick
    
}
