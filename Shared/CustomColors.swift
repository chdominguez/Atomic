//
//  CustomColors.swift
//  Atomic
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI

// Depending on the platform, different color frameworks have to be used
#if os(iOS)
import UIKit
typealias UColor = UIColor
#elseif os(macOS)
import AppKit
typealias UColor = NSColor
#endif

// Custom colors
extension Color {
    
    /// SceneKit better handles either UIColor or NSColor, UColor transforms to either depending on the platform. uColor is the universal color for both platforms.
    var uColor: UColor {
        return UColor(self)
    }
    
    static let blueGradient1 = LinearGradient(colors: [Color("BlueGradient1"), Color("BlueGradient2")], startPoint: .topTrailing, endPoint: .bottomLeading)
    static let blueGradient2 = LinearGradient(colors: [Color("BlueGradient2"), Color("BlueGradient1")], startPoint: .topTrailing, endPoint: .bottomLeading)
    
    static let neumorStart = Color("Neumorphic-start")
    static let neumorEnd = Color("Neumorphic-end")
    static let neumorShadow = Color("NeumorShadow")
    
}

