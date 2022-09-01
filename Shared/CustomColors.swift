//
//  CustomColors.swift
//  Atomic
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

// Custom colors
extension Color {
        
    static let blueGradient1 = LinearGradient(colors: [Color("BlueGradient1"), Color("BlueGradient2")], startPoint: .topTrailing, endPoint: .bottomLeading)
    static let blueGradient2 = LinearGradient(colors: [Color("BlueGradient2"), Color("BlueGradient1")], startPoint: .topTrailing, endPoint: .bottomLeading)
    
    static let neumorStart = Color("Neumorphic-start")
    static let neumorEnd = Color("Neumorphic-end")
    static let neumorShadow = Color("NeumorShadow")
    
}

