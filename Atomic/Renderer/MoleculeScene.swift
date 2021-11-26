//
//  SceneRepresentable.swift
//  SceneRepresentable
//
//  Created by Christian Dominguez on 16/8/21.
//

import Foundation
import SwiftUI
import SceneKit


struct SceneUI: UIViewRepresentable {
    
    @Binding var molecule: Molecule
    @Binding var selectedAtom: Element
    let sceneView = SCNView()
    var scene = SCNScene()
    
    func makeUIView(context: Context) -> SCNView {
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        sceneView.addGestureRecognizer(gesture)
        sceneView.scene = setupScene()
        sceneView.allowsCameraControl = true
        sceneView.defaultCameraController.interactionMode = .orbitTurntable
        sceneView.cameraControlConfiguration.autoSwitchToFreeCamera = true
        sceneView.cameraControlConfiguration.allowsTranslation = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 0.8)
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene?.rootNode.addChildNode(newAtomRender())
    }
    
    func makeCoordinator() -> AtomRenderer {
        AtomRenderer(self)
    }
    
    private func newAtomRender() -> SCNAtomNode {
        let atom = molecule.atoms.last!
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
        return atomNode
    }
    
    
    private func setupScene() -> SCNScene {
        
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
        sceneView.pointOfView = cameraNode

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
        
        var checkedAtoms = molecule.atoms
        
        for atom1 in checkedAtoms {
            checkedAtoms.removeFirst()
            for atom2 in checkedAtoms {
                let pos1 = atom1.position
                let pos2 = atom2.position
                if let cylinderNode = lineBetweenNodes(positionA: pos1, positionB: pos2, inScene: scene, atom1: atom1, atom2: atom2) {
                    scene.rootNode.addChildNode(cylinderNode)
                }
            }
        }
        
        scene.rootNode.addChildNode(atomsNodes)
        
        return scene
    }
    
    private func lineBetweenNodes(positionA: SCNVector3, positionB: SCNVector3, inScene: SCNScene, atom1: Atom, atom2: Atom) -> SCNNode? {
        
        var position1 = positionB
        position1.x = positionB.x + 0.22
        var position2 = positionB
        position2.x = positionB.x - 0.22
        
        let lineNode: SCNNode?
        let lineNode2: SCNNode?
        let vector = SCNVector3(positionA.x - positionB.x, positionA.y - positionB.y, positionA.z - positionB.z)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)
        
        if distance < 2 && atom1.type.canDoubleBond && atom2.type.canDoubleBond {
            let lineGeometry = SCNCylinder()
            let nodes = SCNNode()
            lineNode = SCNNode(geometry: lineGeometry)
            lineNode2 = SCNNode(geometry: lineGeometry)
            lineGeometry.radius = 0.08
            lineGeometry.height = CGFloat(distance)
            lineGeometry.radialSegmentCount = 5
            lineGeometry.firstMaterial!.diffuse.contents = UIColor.gray
            
            var midPosition1 = midPosition
            midPosition1.x = midPosition.x + 0.22

            var midPosition2 = midPosition
            midPosition2.x = midPosition.x - 0.22

            lineNode!.position = midPosition1
            lineNode!.look(at: position1, up: inScene.rootNode.worldUp, localFront: lineNode!.worldUp)
            
            lineNode2!.position = midPosition2
            lineNode2!.look(at: position2, up: inScene.rootNode.worldUp, localFront: lineNode2!.worldUp)
            
            nodes.addChildNode(lineNode!)
            nodes.addChildNode(lineNode2!)
            return nodes
        }
        
        else if distance < 1.2 {
            let lineGeometry = SCNCylinder()
            lineNode = SCNNode(geometry: lineGeometry)
            lineGeometry.radius = 0.1
            lineGeometry.height = CGFloat(distance)
            lineGeometry.radialSegmentCount = 5
            lineGeometry.firstMaterial!.diffuse.contents = UIColor.lightGray
            
            
            lineNode!.position = midPosition
            lineNode!.look(at: positionB, up: inScene.rootNode.worldUp, localFront: lineNode!.worldUp)
            lineNode?.name = "bond"
            return lineNode
        }
        else {
            return nil
        }
    }
}



class SCNAtomNode: SCNNode {
    var atomType: Element!
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


class AtomRenderer: NSObject {
    
    var selectedAtom: Element {PeriodicTableViewController.shared.selectedAtom}
    
    var selected1Tool: level1Tools {ToolsController.shared.selected1Tool}
    
    var selected2Tool: level2Tools {ToolsController.shared.selected2Tool}
    
    var sceneParent: SceneUI
    
    var touch1:SCNVector3?
    
    var touch2:SCNVector3?
    
    var world0: SCNVector3 { sceneParent.sceneView.projectPoint(SCNVector3Zero) }
    
    var selectedAtoms: [SCNNode] = []
    
    init(_ sceneView: SceneUI) {
        self.sceneParent = sceneView
    }
    
    @objc func handleTaps(gesture: UIGestureRecognizer) {
        
        
        let location = gesture.location(in: sceneParent.sceneView)
        let position = SCNVector3(location.x, location.y, CGFloat(world0.z))
        let unprojected = sceneParent.sceneView.unprojectPoint(position)
        
        switch selected2Tool {
        case .addAtom:
            let atom = Atom(id: UUID(), position: unprojected, type: selectedAtom, number: sceneParent.molecule.atoms.count + 1)
            sceneParent.molecule.atoms.append(atom)
            print("AddAtom")
        case .removeAtom:
            let hitResult = sceneParent.sceneView.hitTest(location).first
            let hitNode = hitResult?.node
            hitNode?.removeFromParentNode()
            print("RemoveAtom")
        case .selectAtom:
            let hitResult = sceneParent.sceneView.hitTest(location).first
            if let hitNode = hitResult?.node {
                if hitNode.name == "atom" {
                    let atomOrbSelection = SCNNode()
                    atomOrbSelection.position = hitNode.position
                    
                    let selectionOrb = SCNSphere()
                    
                    selectionOrb.radius = CGFloat(hitNode.geometry!.boundingSphere.radius + 0.1)
                    
                    let selectionMaterial = SCNMaterial()
                    
                    selectionMaterial.diffuse.contents = UIColor.blue
                    
                    
                    selectionOrb.materials = [selectionMaterial]
                    
                    atomOrbSelection.name = "selection"
                    atomOrbSelection.geometry = selectionOrb
                    
                    atomOrbSelection.opacity = 0.3
                    sceneParent.scene.rootNode.addChildNode(atomOrbSelection)
                    
                }
                else if hitNode.name == "selection"  {
                    hitNode.removeFromParentNode()
                }
            }
        }
    }
    
}


