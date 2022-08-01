//
//  UsefulFunctions.swift
//  Atomic
//
//  Created by Christian Dominguez on 8/4/22.
//

import SceneKit
import SceneKitPlus

/// Returns the distance from two separated positions
/// - Parameters:
///   - pos1: Position of atom 1
///   - pos2: position of atom 2
/// - Returns: The square root of the diference of the vectors
func distance(from pos1: SCNVector3, to pos2: SCNVector3) -> Double {
    let distanceVector = pos1 - pos2
    return Double(distanceVector.magnitudeSquared)
}

/// Returns the angle between three vectors in degrees
func angle(pos1: SCNVector3, pos2: SCNVector3, pos3: SCNVector3) -> Double {
    let vector1 = (pos1 - pos2).normalized()
    let vector2 = (pos3 - pos2).normalized()
    
    let dotProduct = vector1.dotProduct(vector2)
    
    return acos(Double(dotProduct)).toDegrees() /// Conversion to degrees
}


/// Computes the average position given an array of positions
/// - Parameter positions: An array with all the atomic positions
/// - Returns: The average position in space
func averageDistance(of positions: [SCNVector3]) -> SCNVector3 {
    
    var meanPos = SCNVector3Zero.self
    
    #warning("TODO: Think of a universal solution for CGFloat/Float duality") // Its done with UFloat, but changes are still to be applied
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

/// Returns the biggest distance (CGFloat number) either from the x axis or the y axis between positions.
/// - Parameter positions: The positions of the atoms to compare
/// - Returns: The value that corresponds to the biggest distance in either axis
func viewingZPositionCGFloat(toSee positions: [SCNVector3]) -> CGFloat {
    
    if positions.isEmpty {
        return 0
    }
    
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

/// Returns the biggest distance (Float number) either from the x axis or the y axis between positions.
/// - Parameter positions: The positions of the atoms to compare
/// - Returns: The value that corresponds to the biggest distance in either axis
func viewingZPosition(toSee positions: [SCNVector3]) -> UFloat {
    
    if positions.count < 2 {
        return 0
    }
    
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
    
    return distanceX >= distanceY ? UFloat(distanceX) : UFloat(distanceY)
    
}

/// Filters a string value to a integer value between a max and a min value
/// - Parameters:
///   - newValue: String to filter
///   - maxValue: Max value allowed
///   - minValue: Min value allowed
/// - Returns: An integer of the filtered string or the minimum value in case the string is empty
func filterStoI(_ newValue: String, maxValue: Int, minValue: Int = 1) -> Int {
    
    if newValue.isEmpty { return minValue }
    
    let filtered = Int(newValue.filter { "0123456789".contains($0) }) ?? 1
    
    if filtered < minValue {
        return minValue
    }
    
    if filtered > maxValue {
        return maxValue
    }

    return filtered // Fallthrough
}

/// Filters a string value to a double value between a max and a min value.
/// - Parameters:
///   - newValue: String to filter
///   - maxValue: Max value allowed
///   - minValue: Min value allowed
/// - Returns: The double of the filtered string or the min value if the string cannot be converted
func filterStoD(_ newValue: String, maxValue: Double, minValue: Double = 0, decimals: Int = 3) -> Double {
    
    if newValue.isEmpty { return minValue }
    
    let filtered = Double(newValue.filter { "0123456789.".contains($0) }) ?? minValue
    
    if filtered < minValue {
        return minValue
    }
    
    if filtered > maxValue {
        return maxValue
    }

    return filtered // Fallthrough
}
