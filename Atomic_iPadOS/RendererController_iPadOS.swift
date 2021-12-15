//
//  RendererController.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/12/21.
//

import SwiftUI
import SceneKit


class RendererController: ObservableObject {
    
    @Published var selectedAtoms: [(atom: SCNNode, orb: SCNNode)] = []
    @Published var molecule: Molecule?
    
    @Published var scene = SCNScene()
    
    func resetRenderer() {
        scene = SCNScene()
        selectedAtoms.removeAll()
        molecule = nil
    }
    
    func newAtomRender() {
        let atom = molecule!.atoms.last!
        let radius = atom.type.radius
        let sphere = SCNSphere(radius: radius)
        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        let frame = radius*4
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame*200, height: frame*100))
        view.backgroundColor = atom.type.color
        let label = UILabel(frame: CGRect(x: 0, y: frame*35, width: frame*200, height: frame*30))
        label.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(label)
        label.textAlignment = .center
        label.text = String(atom.number)
        label.textColor = .black
        
        let atomNode = SCNAtomNode()
        atomNode.atomType = atom.type
        atomNode.physicsBody = physicsBody
        
        let material = SCNMaterial()
        material.diffuse.contents = view.asImage()
        
        atomNode.geometry = sphere
        atomNode.geometry!.materials = [material]
        atomNode.position = atom.position
        
        atomNode.constraints = [SCNBillboardConstraint()]
        scene.rootNode.addChildNode(atomNode)
    }
    
    func setupScene() {
        
        let atomsNodes = SCNNode()
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .ambient
        lightNode.light?.intensity = 0.9
        lightNode.position = SCNVector3(x:0, y:2, z:20)
        
        let cameraNode = SCNNode()
        let cameraItem = SCNCamera()
        cameraNode.camera = cameraItem
        cameraNode.position = SCNVector3(0, 0, 20)
        
        scene.rootNode.addChildNode(cameraNode)
        
        guard let molecule = molecule else {
            print("NO MOLECULE")
            return
        }
        
        for atom in molecule.atoms {
            let radius = atom.type.radius
            let sphere = SCNSphere(radius: radius)
            let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            
            let frame = radius*4
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: frame*200, height: frame*100))
            view.backgroundColor = atom.type.color
            let label = UILabel(frame: CGRect(x: 0, y: frame*35, width: frame*200, height: frame*30))
            label.font = UIFont.systemFont(ofSize: 20)
            view.addSubview(label)
            label.textAlignment = .center
            label.text = String(atom.number)
            label.textColor = .black
            
            let atomNode = SCNAtomNode()
            atomNode.atomType = atom.type
            atomNode.physicsBody = physicsBody
            
            let material = SCNMaterial()
            material.diffuse.contents = view.asImage()
            
            atomNode.geometry = sphere
            atomNode.geometry!.materials = [material]
            atomNode.position = atom.position
            
            atomNode.constraints = [SCNBillboardConstraint()]
            atomNode.name = "atom"
            atomsNodes.addChildNode(atomNode)
        }
        scene.rootNode.addChildNode(atomsNodes)
        checkBondingBasedOnDistance()
    }
    
    func bondSelectedAtoms() {
        if selectedAtoms.count == 2 {
            let atom1 = selectedAtoms[0].atom
            let atom2 = selectedAtoms[1].atom
            let position1 = atom1.position
            let position2 = atom2.position
            lineBetweenNodes(positionA: position1, positionB: position2)
        }
    }
    
    func eraseSelectedAtoms() {
        for atom in selectedAtoms {
            atom.atom.removeFromParentNode()
            atom.orb.removeFromParentNode()
        }
        selectedAtoms.removeAll()
    }
    
    private func checkBondingBasedOnDistance() {
        var compareArray = molecule!.atoms
        for atom1 in compareArray {
            compareArray.remove(at: 0)
            for atom2 in compareArray {
                let pos1 = atom1.position
                let pos2 = atom2.position
                let x = (pos1.x - pos2.x)
                let y = (pos1.y - pos2.y)
                let z = (pos1.z - pos2.z)
                let distance = sqrt(x*x+y*y+z*z)
                if distance < 1.2 {
                    lineBetweenNodes(positionA: pos1, positionB: pos2)
                }
            }
        }

    }
    
    private func lineBetweenNodes(positionA: SCNVector3, positionB: SCNVector3) {
        let vector = SCNVector3(positionA.x - positionB.x, positionA.y - positionB.y, positionA.z - positionB.z)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)
        
        let lineGeometry = SCNCylinder()
        lineGeometry.radius = 0.1
        lineGeometry.height = CGFloat(distance)
        lineGeometry.radialSegmentCount = 5
        lineGeometry.firstMaterial!.diffuse.contents = UIColor.lightGray
        
        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = midPosition
        lineNode.look(at: positionB, up: scene.rootNode.worldUp, localFront: lineNode.worldUp)
        lineNode.name = "bond"
        scene.rootNode.addChildNode(lineNode)
        
    }
}
