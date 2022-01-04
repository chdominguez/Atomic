//
//  GaussianGJFWriter.swift
//  Atomic
//
//  Created by Christian Dominguez on 3/1/22.
//

import SceneKit


class GJFWritter {
    
    static func SceneToGJF(scene: SCNScene) -> String {
        
        var fileToBeSaved: String = ""

        scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "atom" {
                let posx = node.position.x
                let posy = node.position.y
                let posz = node.position.z
                fileToBeSaved += "\(posx)\t" + "\(posy)\t" + "\(posz)\n"
            }
        }
        return fileToBeSaved
    }
}
