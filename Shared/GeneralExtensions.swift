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
    
    /// Truncates a double to show only the given decimals
    func truncate(to places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
    
    /// Transforms the angle defined by this value from degrees to radians.
    func toRadians() -> Double {
        return self * (.pi / 180)
    }
    
    /// Transforms the angle defined by this value from radians to degrees.
    func toDegrees() -> Double {
        return self * (180 / .pi)
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
