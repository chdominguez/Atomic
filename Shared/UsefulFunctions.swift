//
//  UsefulFunctions.swift
//  Atomic
//
//  Created by Christian Dominguez on 8/4/22.
//

import SceneKit


/// Returns the distance from two separated positions
/// - Parameters:
///   - pos1: Position of atom 1
///   - pos2: position of atom 2
/// - Returns: The square root of the diference of the vectors
func distance(from pos1: SCNVector3, to pos2: SCNVector3) -> Double {
    let x = (pos1.x - pos2.x), y = (pos1.y - pos2.y), z = (pos1.z - pos2.z)
    return Double(sqrt(x*x+y*y+z*z))
}


/// Computes the average position given an array of positions
/// - Parameter positions: An array with all the atomic positions
/// - Returns: The average position in space
func averageDistance(of positions: [SCNVector3]) -> SCNVector3 {
    
    var meanPos = SCNVector3Zero.self
    
    // Why does SceneKit uses Floats or CGFloats depending on the OS. WHY?
    #if os(macOS)
    let npos = CGFloat(positions.count)
    #elseif os(iOS)
    let npos = Float(positions.count)
    #endif
    
    for position in positions {
        meanPos.x += position.x / npos
        meanPos.y += position.y / npos
        meanPos.z += position.z / npos
    }
    return meanPos
}

/// Returns the biggest distance either from the x axis or the y axis between positions. Useful wehn computen distances between atoms
/// - Parameter positions: The positions of the atoms to compare
/// - Returns: The value that corresponds to the biggest distance in either axis
func viewingZPositionCGFloat(toSee positions: [SCNVector3]) -> CGFloat {
    
    var maxx = positions.first!.x
    var minx = positions.first!.x
    
    var maxy = positions.first!.y
    var miny = positions.first!.y
    
    for position in positions {
        if position.x > maxx {
            maxx = position.x
        }
        if position.x < minx {
            minx = position.x
        }
        if position.y > maxy {
            maxy = position.x
        }
        if position.y < miny {
            miny = position.x
        }
    }
    
    let distanceX = maxx - minx
    let distanceY = maxy - miny
    
    return distanceX >= distanceY ? CGFloat(distanceX) : CGFloat(distanceY)
    
}

func viewingZPositionFloat(toSee positions: [SCNVector3]) -> Float {
    
    var maxx = positions.first!.x
    var minx = positions.first!.x
    
    var maxy = positions.first!.y
    var miny = positions.first!.y
    
    for position in positions {
        if position.x > maxx {
            maxx = position.x
        }
        if position.x < minx {
            minx = position.x
        }
        if position.y > maxy {
            maxy = position.x
        }
        if position.y < miny {
            miny = position.x
        }
    }
    
    let distanceX = maxx - minx
    let distanceY = maxy - miny
    
    return distanceX >= distanceY ? Float(distanceX) : Float(distanceY)
    
}
