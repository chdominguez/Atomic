//
//  GaussianGJFWriter.swift
//  Atomic
//
//  Created by Christian Dominguez on 3/1/22.
//

import SceneKit


class GJFWritter {
    
    static func sceneToGJF(scene: SCNScene) -> String {
        
        var fileToBeSaved: String = ""
        
        scene.rootNode.enumerateChildNodes { node, _ in
            guard let atomName = node.name else {return}
            if atomName.contains("atom") {
                let posx = node.position.x.stringWith(5)
                let posy = node.position.y.stringWith(5)
                let posz = node.position.z.stringWith(5)
                let atomType = atomName.split(separator: "_")[1]
                fileToBeSaved += "\(atomType)\t\t \(posx)\t\t \(posy)\t\t \(posz)\n"
            }
        }
        return fileToBeSaved
    }
}
