//
//  GaussianGJFWriter.swift
//  Atomic
//
//  Created by Christian Dominguez on 3/1/22.
//

import SceneKit


class XYZWritter {
    
    #warning("TODO: Fix saving files")
    
    static func sceneToXYZ(atomNodes: SCNNode) -> xyzFile {
        
        var fileToBeSaved: String = ""
        var natoms: Int = 0
        
        atomNodes.enumerateChildNodes { node, _ in
            guard let atomName = node.name else {return}
            natoms += 1
            let posx = node.position.x.stringWith(5)
            let posy = node.position.y.stringWith(5)
            let posz = node.position.z.stringWith(5)
            let atomType = atomName.split(separator: "_")[1]
            fileToBeSaved += "\(atomType)\t\t \(posx)\t\t \(posy)\t\t \(posz)\n"
        }
        
        fileToBeSaved = "\(natoms)\n" + "Written by Atomic\n" + fileToBeSaved
        
        let file = xyzFile(initialText: fileToBeSaved)
        
        return file
    }
}
