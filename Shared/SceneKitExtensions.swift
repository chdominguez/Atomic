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
    
    // Double counterparts of the x,y and z variables
    var dx: Double { get {Double(x)} set {x = UFloat(newValue)} }
    var dy: Double { get {Double(y)} set {y = UFloat(newValue)} }
    var dz: Double { get {Double(z)} set {z = UFloat(newValue)} }
    
    /// Returns the normalized vector
    func normalized() -> SCNVector3 {
        return SCNVector3Make(UFloat(dx / magnitudeSquared), UFloat(dy / magnitudeSquared), UFloat(dz / magnitudeSquared))
    }
    
    /// Returns the dot product between itself and a second vector.
    func dotProduct(_ v2: SCNVector3) -> Double {
        dx * v2.dx + dy * v2.dy + dz * v2.dz
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
        SCNVector3Make(UFloat(dx*rhs), UFloat(dy*rhs), UFloat(dz*rhs))
    }
    
    func rotated(by angle: Double, withRespectTo n: SCNVector3) -> SCNVector3 {
        
        let firstTerm = self.scaled(by: cos(angle))
        let secondTerm = (n.crossProduct(self)).scaled(by: sin(angle))
        let thridTerm = n.scaled(by: (1 - cos(angle))*(n.dotProduct(self)))
        
        return firstTerm + secondTerm + thridTerm
        
    }
    
    func getSimd() -> SIMD3<Double> {
        return SIMD3(self)
    }
      
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

extension SCNQuaternion {
    public init(axis: SCNVector3, angle: Double) {
        self = SCNQuaternion(axis.x, axis.y, axis.z, UFloat(angle))
    }
}
