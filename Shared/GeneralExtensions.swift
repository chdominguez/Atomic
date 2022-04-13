//
//  Extensions.swift
//  Atomic
//
//  Created by Christian Dominguez on 5/1/22.
//

import CoreGraphics
import SceneKit


extension Double {
    /// Returns a string of the self value with the designed decimals
    /// - Parameter decimals: Number of decimals after the comma
    /// - Returns: String of the formatted number
    func stringWith(_ decimals: Int) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}

extension CGFloat {
    /// Returns a string of the self value with the designed decimals
    /// - Parameter decimals: Number of decimals after the comma
    /// - Returns: String of the formatted number
    func stringWith(_ decimals: Int) -> String {
        if self < 0 {
            return String(format: "%.\(decimals)f", self)
        }
        else {
            return " \(String(format: "%.\(decimals)f", self))"
        }
    }
}

extension Float {
    /// Returns a string of the self value with the designed decimals
    /// - Parameter decimals: Number of decimals after the comma
    /// - Returns: String of the formatted number
    func stringWith(_ decimals: Int) -> String {
        if self < 0 {
            return String(format: "%.\(decimals)f", self)
        }
        else {
            return " \(String(format: "%.\(decimals)f", self))"
        }
    }
}

extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        if lhs.x == rhs.x {
            if lhs.y == rhs.y {
                if  lhs.z == rhs.z {
                    return true
                }
            }
        }
        return false
    }
}
