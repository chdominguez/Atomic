//
//  SceneKitExtensions.swift
//  Atomic
//
//  Created by Christian Dominguez on 18/4/22.
//

import SceneKit
import SwiftUI

///Universal Float (iOS) or CGFloat (macOS) depending on the platform
#if os(macOS)
typealias UFloat = CGFloat
#elseif os(iOS)
typealias UFloat = Float
#endif

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

/// Make SCNVector3s to be added and substracted
extension SCNVector3: AdditiveArithmetic {
    
    public static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3Make(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    public static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3Make(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    public static var zero: SCNVector3 {
        return SCNVector3Make(0, 0, 0)
    }
}


/// Useful functions for vectors

extension SCNVector3 {
    
    /// Returns the normalized vector
    func normalized() -> SCNVector3 {
        return SCNVector3Make(dx / magnitudeSquared, dy / magnitudeSquared, dz / magnitudeSquared)
    }
    
    /// Returns the dot product between itself and a second vector.
    func dotProduct(_ v2: SCNVector3) -> Float {
        Float(x * v2.x + y * v2.y + z * v2.z)
    }
    
    /// Returns the cross product between itself and a second vector.
    func crossProduct(_ v2: SCNVector3) -> SCNVector3 {
        let nx = y*v2.z - z*v2.y
        let ny = z*v2.x - x*v2.z
        let nz = x*v2.y - y*v2.x
        return SCNVector3Make(nx, ny, nz)
    }
    
    /// Returns the scaled vector without modifying the original vector
    func scaled(by rhs: Double) -> SCNVector3 {
        SCNVector3Make(dx*rhs, dy*rhs, dz*rhs)
    }
    
    // Double counterparts of the x,y and z variables
    var dx: Double { get {Double(x)} set {x = UFloat(newValue)} }
    var dy: Double { get {Double(y)} set {y = UFloat(newValue)} }
    var dz: Double { get {Double(z)} set {z = UFloat(newValue)} }
      
}

extension SCNVector3: VectorArithmetic {
    
    /// Scales and modifies the vector
    public mutating func scale(by rhs: Double) {
        dx *= rhs
        dy *= rhs
        dz *= rhs
    }
    /// The magnitude of the vector
    public var magnitudeSquared: Double {
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
}

extension CGFloat {
    /// Initializes a CGFloat with a string
    public init?(_ string: String) {
        guard let float = Float(string) else {return nil}
        self = CGFloat(Float(float))
    }
}
