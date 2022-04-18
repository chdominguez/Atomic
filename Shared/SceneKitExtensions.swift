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

    func dotProduct(_ v2: SCNVector3) -> Float {
        self.x * v2.x + self.y * v2.y + self.z * v2.z
    }
    
    func normalized() -> SCNVector3 {
        SCNVector3Make(self.x / norm, self.y / norm, self.z / norm)
    }
      
}
