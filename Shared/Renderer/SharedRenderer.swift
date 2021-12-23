//
//  SharedRenderer.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/12/21.
//
import SwiftUI
import SceneKit

#if os(iOS) || os(tvOS)
import UIKit
typealias RView = UIView
typealias RColor = UIColor
typealias TapGesture = UITapGestureRecognizer
#elseif os(OSX)
import AppKit
typealias RView = NSView
typealias RColor = NSColor
typealias TapGesture = NSClickGestureRecognizer
#endif

class RendererController: ObservableObject {
    
    var timer = Timer()
    let steps: [Step]
    var atomChildNodes: [SCNNode] = []
    
    @Published var sceneView = SCNView()
    @Published var scene = SCNScene()

    @Published var didLoadAtLeastOne: Bool = false {
        didSet {
            updateChildNode()
        }
    }
    @Published var showingStep: Step {
        didSet {
            updateChildNode()
        }
    }
    @Published var selectedAtoms: [(atom: SCNNode, orb: SCNNode)] = []
    @Published var didLoadAllScenes = false
    @Published var selectedIndex = 0
    @Published var progress = 0.0
    @Published var stepsPreloaded = 0
    @Published var isPlaying = false
    
    var currentChildNode: SCNNode? {
        if atomChildNodes.isEmpty {
            return nil
        }
        else {
            return atomChildNodes[selectedIndex]
        }
    }
    
    init(_ steps: [Step]) {
        self.steps = steps
        self.showingStep = steps.first!
    }
    
    private func updateChildNode() {
        guard let currentChildNode = currentChildNode else {
            return
        }
        scene.rootNode.childNode(withName: "Step", recursively: true)?.removeFromParentNode()
        scene.rootNode.addChildNode(currentChildNode)
    }
    
    func playAnimation() {
        if isPlaying {
            timer.invalidate()
        }
        else {
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                self.nextScene()
            }
        }
        isPlaying.toggle()
    }
    
    func nextScene() {
        let count = atomChildNodes.count
        if selectedIndex == count - 1 {
            selectedIndex = 0
        }
        else {
            selectedIndex += 1
        }
        showingStep = steps[selectedIndex]
    }
    
    func previousScene() {
        let count = atomChildNodes.count
        if selectedIndex == 0 {
            selectedIndex = count - 1
        }
        else {
            selectedIndex -= 1
        }
        showingStep = steps[selectedIndex]
    }
    
    func loadAllScenes() {
        let totalSteps = Double(steps.count)
        let progressStep = 1 / totalSteps
        DispatchQueue.global(qos: .background).async { [self] in
            for step in steps {
                let newNode = setupScene(step: step)
                newNode.name = "Step"
                atomChildNodes.append(newNode)
                DispatchQueue.main.sync {
                    progress += progressStep
                    stepsPreloaded += 1
                    didLoadAtLeastOne = true
                }
            }
            DispatchQueue.main.sync {
                self.didLoadAllScenes = true
            }
        }
    }
    
    func resetRenderer() {
        didLoadAllScenes = false
        didLoadAtLeastOne = false
        selectedIndex = 0
        progress = 0
        atomChildNodes.removeAll()
        selectedAtoms.removeAll()
    }
    
//    func newAtomRender() {
//        let atom = molecule!.atoms.last!
//        let radius = atom.type.radius
//        let sphere = SCNSphere(radius: radius)
//        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//
//        let frame = radius*4
//
//        let view = NSView(frame: CGRect(x: 0, y: 0, width: frame*200, height: frame*100))
//        view.window?.backgroundColor = NSColor(atom.type.color)
//        let label = NSTextField(frame: NSRect(x: 0, y: frame*35, width: frame*200, height: frame*30))
//        label.font = NSFont.systemFont(ofSize: 20)
//        view.addSubview(label)
//        label.alignment = .center
//        label.stringValue = String(atom.number)
//        label.textColor = .black
//        label.isEditable = false
//        label.sizeToFit()
//
//        let atomNode = SCNAtomNode()
//        atomNode.atomType = atom.type
//        atomNode.physicsBody = physicsBody
//
//        let material = SCNMaterial()
//        material.diffuse.contents = view
//
//        atomNode.geometry = sphere
//        atomNode.geometry!.materials = [material]
//        atomNode.position = atom.position
//
//        atomNode.constraints = [SCNBillboardConstraint()]
//        scene.rootNode.addChildNode(atomNode)
//    }
    
    func setupScene(step: Step) -> SCNNode {
        
        var atomsNodes = SCNNode()
        
        for atom in step.molecule.atoms {
            let radius = atom.type.radius
            let sphere = SCNSphere(radius: radius)
            let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            
//            let frame = radius*4
            
//            let view = NSView(frame: CGRect(x: 0, y: 0, width: frame*200, height: frame*100))
//            view.wantsLayer = true
//            view.layer?.backgroundColor = NSColor(atom.type.color).cgColor
//            let label = NSTextField(frame: CGRect(x: 0, y: frame*25, width: frame*200, height: frame*30))
//            label.font = NSFont.systemFont(ofSize: 20)
//            label.alignment = .center
//            label.stringValue = String(atom.number)
//            label.textColor = NSColor.black
//            label.isBezeled = false
//            label.drawsBackground = false
//            label.isEditable = false
            
//            let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
//            view.cacheDisplay(in: view.bounds, to: rep)

//            let img = NSImage(size: view.bounds.size)
//            img.addRepresentation(rep)
            
            let atomNode = SCNAtomNode()
            atomNode.atomType = atom.type
            atomNode.physicsBody = physicsBody
            
            let material = SCNMaterial()
            material.diffuse.contents = RColor(atom.type.color)
            
            atomNode.geometry = sphere
            atomNode.geometry!.materials = [material]
            atomNode.position = atom.position
            
            atomNode.constraints = [SCNBillboardConstraint()]
            atomNode.name = "atom"
            atomsNodes.addChildNode(atomNode)
        }
        
        atomsNodes = checkBondingBasedOnDistance(node: atomsNodes, molecule: step.molecule)
        
        return atomsNodes
    }
    
    func bondSelectedAtoms() {
        if selectedAtoms.count == 2 {
            let atom1 = selectedAtoms[0].atom
            let atom2 = selectedAtoms[1].atom
            let position1 = atom1.position
            let position2 = atom2.position
            let currentNode = atomChildNodes[selectedIndex]
            let bonds = lineBetweenNodes(node: currentNode, positionA: position1, positionB: position2)
            currentNode.addChildNode(bonds)
        }
    }
    
    func eraseSelectedAtoms() {
        for atom in selectedAtoms {
            atom.atom.removeFromParentNode()
            atom.orb.removeFromParentNode()
        }
        selectedAtoms.removeAll()
    }
    
    private func checkBondingBasedOnDistance(node: SCNNode, molecule: Molecule) -> SCNNode {
        var compareArray = molecule.atoms
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
                    node.addChildNode(lineBetweenNodes(node: node, positionA: pos1, positionB: pos2))
                }
            }
        }
        return node

    }
    
    private func lineBetweenNodes(node: SCNNode, positionA: SCNVector3, positionB: SCNVector3) -> SCNNode {
        let vector = SCNVector3(positionA.x - positionB.x, positionA.y - positionB.y, positionA.z - positionB.z)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)
        
        let lineGeometry = SCNCylinder()
        lineGeometry.radius = 0.1
        lineGeometry.height = CGFloat(distance)
        lineGeometry.radialSegmentCount = 5
        lineGeometry.firstMaterial!.diffuse.contents = RColor.lightGray
        
        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = midPosition
        lineNode.look(at: positionB, up: node.worldUp, localFront: lineNode.worldUp)
        lineNode.name = "bond"
        
        return lineNode
        
    }
}

class AtomRenderer: NSObject {
    
    @ObservedObject var controller: RendererController
        
    var selectedAtom: Element {PeriodicTableViewController.shared.selectedAtom}
    
    var selected1Tool: mainTools {ToolsController.shared.selected1Tool}
    
    var selected2Tool: editTools {ToolsController.shared.selected2Tool}
    
    var sceneParent: SceneUI
    
    var touch1:SCNVector3?
    
    var touch2:SCNVector3?
    
    var world0: SCNVector3 { controller.sceneView.projectPoint(SCNVector3Zero) }
    
    init(_ sceneView: SceneUI, controller: RendererController) {
        self.sceneParent = sceneView
        self.controller = controller
    }
    
    @objc func handleTaps(gesture: TapGesture) {
        
        let location = gesture.location(in: controller.sceneView)
        //let position = SCNVector3(location.x, location.y, CGFloat(world0.z))
        //let unprojected = sceneParent.sceneView.unprojectPoint(position)
        
        switch selected2Tool {
        case .addAtom:
            print("WIP")
//            let atom = Atom(id: UUID(), position: unprojected, type: selectedAtom, number: controller.molecule!.atoms.count + 1)
//            controller.molecule!.atoms.append(atom)
//            controller.newAtomRender()
        case .removeAtom:
            let hitResult = controller.sceneView.hitTest(location).first
            let hitNode = hitResult?.node
            hitNode?.removeFromParentNode()
        case .selectAtom:
            let hitResult = controller.sceneView.hitTest(location).first
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
                    controller.sceneView.scene?.rootNode.addChildNode(atomOrbSelection)
                    
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
                    controller.sceneView.scene?.rootNode.addChildNode(atomOrbSelection)
                    
                    controller.selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
                }

            }
            else {
                print("*** Else")
                controller.selectedAtoms.removeAll()
                controller.sceneView.scene?.rootNode.childNodes.filter({ $0.name == "selection" }).forEach({ $0.removeFromParentNode() })

            }
        }
        
    }
    

}

class SCNAtomNode: SCNNode {
    var atomType: Element!
}
