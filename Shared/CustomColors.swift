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
    static let buttonGradient = LinearGradient(colors: [Color("ButtonColor1"), Color("ButtonColor2")], startPoint: .topTrailing, endPoint: .bottomLeading)
    
    /// SceneKit better handles either UIColor or NSColor, RColor transforms to either depending on the platform. uColor is the universal color for both platforms.
    var uColor: UColor {
        return UColor(self)
    }
    
}

