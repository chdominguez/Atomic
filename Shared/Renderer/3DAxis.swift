//
//  3DCoordinates.swift
//  Atomic
//
//  Created by Christian Dominguez on 5/9/22.
//

import Foundation
import SceneKit
import SceneKitPlus

extension MoleculeRenderer {
    
    private func createLine(from: SCNVector3, to: SCNVector3) -> SCNNode {
        let midPosition = SCNVector3((to.x + from.x) / 2,(to.y + from.y) / 2,(to.z + from.z) / 2)
        let lineNode = SCNNode()
        lineNode.position = midPosition
        lineNode.look(at: to, up: scene!.rootNode.worldUp, localFront: lineNode.worldUp)
        
        let distance = distance(from: from, to: to)
        
        let cylinder = SCNNode(geometry: SCNCylinder(radius: 0.05, height: distance))
        
        let cone = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2))
        cone.position = SCNVector3(0, distance/2, 0)
        //cone.look(at: to, up: scene!.rootNode.worldUp, localFront: cone.worldUp)
        //cone.look(at: from, up: scene!.rootNode.worldUp, localFront: lineNode.worldUp)
        
        lineNode.addChildNode(cylinder)
        lineNode.addChildNode(cone)
        
        return lineNode
    }
    
    func generate3DAxis() -> SCNNode {
        let start = SCNVector3(0, 0, 0)
        let end = 1.2
        let xaxis = createLine(from: start, to: SCNVector3(end, 0, 0))
        xaxis.name = "xaxis"
        let yaxis = createLine(from: start, to: SCNVector3(0, end, 0))
        yaxis.name = "yaxis"
        let zaxis = createLine(from: start, to: SCNVector3(0, 0, end))
        zaxis.name = "zaxis"
        
        xaxis.enumerateChildNodes { node, _ in
            node.geometry?.materials.first?.diffuse.contents = UColor.red
        }
        yaxis.enumerateChildNodes { node, _ in
            node.geometry?.materials.first?.diffuse.contents = UColor.blue
        }
        
        zaxis.enumerateChildNodes { node, _ in
            node.geometry?.materials.first?.diffuse.contents = UColor.green
        }
        
        let axisNode = SCNNode()
        axisNode.addChildNode(xaxis)
        axisNode.addChildNode(yaxis)
        axisNode.addChildNode(zaxis)
        axisNode.geometry?.materials.first?.readsFromDepthBuffer = false
        axisNode.renderingOrder = 5
        axisNode.name = "axis"
        return axisNode
    }
}
