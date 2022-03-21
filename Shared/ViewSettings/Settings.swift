//
//  Settings.swift
//  Atomic_ipad
//
//  Created by Christian Dominguez on 21/3/22.
//

import Foundation
import SceneKit


struct RenderSettings {
    let geometry: SCNGeometry
    let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    let constraints = [SCNBillboardConstraint()]
    
    
    init() {
        let geometry = SCNSphere(radius: 1)
        let material = SCNMaterial()
        
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.4
        material.roughness.contents = 0.5
        
        geometry.materials = [material]
        
        self.geometry = geometry
    }
    
}
