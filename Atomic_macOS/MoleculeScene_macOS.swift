//
//  MoleculeScene_macOS.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI
import SceneKit

struct SceneUI: NSViewRepresentable {
    
    @ObservedObject var controller: RendererController

    let sceneView = SCNView()
    
    func makeNSView(context: Context) -> SCNView {
        let gesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        sceneView.addGestureRecognizer(gesture)
        sceneView.allowsCameraControl = true
        sceneView.defaultCameraController.interactionMode = .orbitTurntable
        sceneView.cameraControlConfiguration.autoSwitchToFreeCamera = true
        sceneView.cameraControlConfiguration.allowsTranslation = true
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }
    
    func updateNSView(_ uiView: SCNView, context: Context) {
        controller.setupScene()
        sceneView.scene = controller.scene
    }
    
    func makeCoordinator() -> AtomRenderer {
        AtomRenderer(self, controller: controller)
    }
}




class SCNAtomNode: SCNNode {
    var atomType: Element!
}


class AtomRenderer: NSObject {
    
    @ObservedObject var controller: RendererController
        
    var selectedAtom: Element {PeriodicTableViewController.shared.selectedAtom}
    
    var selected1Tool: mainTools {ToolsController.shared.selected1Tool}
    
    var selected2Tool: editTools {ToolsController.shared.selected2Tool}
    
    var sceneParent: SceneUI
    
    var touch1:SCNVector3?
    
    var touch2:SCNVector3?
    
    var world0: SCNVector3 { sceneParent.sceneView.projectPoint(SCNVector3Zero) }
    
    init(_ sceneView: SceneUI, controller: RendererController) {
        self.sceneParent = sceneView
        self.controller = controller
    }
    
    @objc func handleTaps(gesture: NSClickGestureRecognizer) {
        
        let location = gesture.location(in: sceneParent.sceneView)
        let position = SCNVector3(location.x, location.y, CGFloat(world0.z))
        let unprojected = sceneParent.sceneView.unprojectPoint(position)
        
        switch selected2Tool {
        case .addAtom:
            let atom = Atom(id: UUID(), position: unprojected, type: selectedAtom, number: controller.molecule!.atoms.count + 1)
            controller.molecule!.atoms.append(atom)
            controller.newAtomRender()
        case .removeAtom:
            let hitResult = sceneParent.sceneView.hitTest(location).first
            let hitNode = hitResult?.node
            hitNode?.removeFromParentNode()
        case .selectAtom:
            let hitResult = sceneParent.sceneView.hitTest(location).first
            if let hitNode = hitResult?.node {
                if hitNode.name == "atom" {
                    let atomOrbSelection = SCNNode()
                    atomOrbSelection.position = hitNode.position
                    
                    let selectionOrb = SCNSphere()
                    
                    selectionOrb.radius = CGFloat(hitNode.geometry!.boundingSphere.radius + 0.1)
                    
                    let selectionMaterial = SCNMaterial()
                    
                    selectionMaterial.diffuse.contents = Color.blue
                    
                    
                    selectionOrb.materials = [selectionMaterial]
                    
                    atomOrbSelection.name = "selection"
                    atomOrbSelection.geometry = selectionOrb
                    
                    atomOrbSelection.opacity = 0.3
                    controller.scene.rootNode.addChildNode(atomOrbSelection)
                    
                    controller.selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
                }
                else if hitNode.name == "selection"  {
                    guard let i = controller.selectedAtoms.firstIndex(where: {$0.orb == hitNode}) else {return}
                    controller.selectedAtoms.remove(at: i)
                    hitNode.removeFromParentNode()
                    
                }
                else if hitNode.name == "bond" {
                    let atomOrbSelection = SCNNode()
                    atomOrbSelection.position = hitNode.position
                    
                    let selectionOrb = SCNSphere()
                    
                    selectionOrb.radius = CGFloat(hitNode.geometry!.boundingSphere.radius + 0.1)
                    
                    let selectionMaterial = SCNMaterial()
                    
                    selectionMaterial.diffuse.contents = Color.blue
                    
                    
                    selectionOrb.materials = [selectionMaterial]
                    
                    atomOrbSelection.name = "selection"
                    atomOrbSelection.geometry = selectionOrb
                    
                    atomOrbSelection.opacity = 0.3
                    controller.scene.rootNode.addChildNode(atomOrbSelection)
                    
                    controller.selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
                }

            }
            else {
                print("*** Else")
                controller.selectedAtoms.removeAll()
                controller.scene.rootNode.childNodes.filter({ $0.name == "selection" }).forEach({ $0.removeFromParentNode() })

            }
        }
        
    }
    

}
