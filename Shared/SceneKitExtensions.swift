//
//  SceneKitExtensions.swift
//  Atomic
//
//  Created by Christian Dominguez on 18/4/22.
//

import SceneKit

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
    
    /// The norm of the vector
    var norm: Float {
        let floatx = Float(x)
        let floaty = Float(y)
        let floatz = Float(z)
        
        return sqrt(floatx*floatx + floaty*floaty + floatz*floatz)
    }
    
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
        let gnorm = CGFloat(norm)
        return SCNVector3Make(x / gnorm, y / gnorm, z / gnorm)
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
      
}
