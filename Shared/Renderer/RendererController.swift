//
//  SharedRenderer.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/12/21.
//
import SwiftUI
import SceneKit

// Depending on the platform, different frameworks have to be used
#if os(iOS)
import UIKit
typealias RView = UIView
typealias RColor = UIColor
typealias TapGesture = UITapGestureRecognizer
#elseif os(macOS)
import AppKit
typealias RView = NSView
typealias RColor = NSColor
typealias TapGesture = NSClickGestureRecognizer
#endif

/// Controls the SceneKit SCNView. Renders the 3D atoms, bonds, handles tap gestures...
class RendererController: ObservableObject {
    
    var timer = Timer()
    let steps: [Step]
    let allGeometries = AllGeometries()
    
    var atomNodes = SCNNode()
    var bondNodes = SCNNode()
    
    let sceneView = SCNView()
    let scene = SCNScene()
    let cameraNode = SCNNode()

    @Published var showingStep: Step {
        didSet {
            //updateChildNode()
            if let _ = showingStep.frequencys {
                CommandMenuController.shared.hasfreq = true
            }
            else {
                CommandMenuController.shared.hasfreq = false
            }
        }
    }
    @Published var selectedAtoms: [(atom: SCNNode, orb: SCNNode)] = []
    @Published var didLoadAtoms = false
    @Published var isPlaying = false
    @Published var playBack = "25"
    @Published var stringStep = "1"
    
    
    init(_ steps: [Step]) {
        self.steps = steps
        self.showingStep = steps.first!
        self.scene.rootNode.addChildNode(atomNodes)
        self.scene.rootNode.addChildNode(bondNodes)
    }
    
    func newAtom(atom: Atom) {
        
        let atomNode = SCNAtomNode()
        
        let radius = atom.type.radius
        let sphere = SCNSphere(radius: radius)

        atomNode.atomType = atom.type
        atomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        let material = SCNMaterial()
        material.diffuse.contents = RColor(ColorSettings.shared.atomColors[atom.type.atomicNumber - 1])
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.4
        material.roughness.contents = 0.5
        
        atomNode.geometry = sphere
        atomNode.geometry!.materials = [material]
        atomNode.position = atom.position
        
        
        //atomNode.constraints = [SCNBillboardConstraint()]
        atomNode.name = "atom_\(atom.type.rawValue)"
        scene.rootNode.addChildNode(atomNode)
    }
    
    func playAnimation() {
        if isPlaying {
            timer.invalidate()
        }
        else {
            timer = Timer.scheduledTimer(withTimeInterval: 1/(Double(playBack) ?? 1), repeats: true) { timer in
                self.nextScene()
            }
        }
        isPlaying.toggle()
    }
    
    func filterValue(_ newValue: String) {
//        if newValue == self.playBack {
//            return
//        }
//        if newValue.isEmpty {
//            self.stringStep = "1"
//        }
//        let filtered = newValue.filter { "0123456789".contains($0) }
//        let intFiltered = Int(filtered) ?? 0
//        if intFiltered < 1 {
//            self.stringStep = "1"
//        }
//        if intFiltered > self.steps.count {
//            self.stringStep = String(self.steps.count)
//        }
//        if filtered != newValue {
//            if filtered.isEmpty {
//                self.stringStep = "1"
//            } else {
//                self.stringStep = filtered
//            }
//        }
    }
    
    func filterPlayBackValue(_ newValue: String) {
        if newValue.isEmpty {
            self.playBack = "1"
        }
        let filtered = newValue.filter { "0123456789".contains($0) }
        let intFiltered = Int(filtered) ?? 1
        if intFiltered < 1 {
            self.playBack = "1"
        }
        if intFiltered > 25 {
            self.playBack = "25"
        }
        if filtered != newValue {
            if filtered.isEmpty {
                self.playBack = "1"
            } else {
                self.playBack = filtered
            }
        }
    }
    
    func nextScene() {
        let count = steps.count
        var intStep = Int(stringStep)! - 1
        if intStep == count - 1 {
            intStep = 0
        }
        else {
            intStep += 1
        }
        self.stringStep = String(intStep + 1)
        moveNodes(toStep: steps[intStep])
    }
    
    func previousScene() {
        let count = steps.count
        var intStep = Int(stringStep)! - 1
        if intStep == 0 {
            intStep = count - 1
        }
        else {
            intStep -= 1
        }
        self.stringStep = String(intStep + 1)
        moveNodes(toStep: steps[intStep])
    }
    
    func loadScenes() {
        DispatchQueue.global(qos: .background).async { [self] in
            setupScene(step: steps.first!)
            DispatchQueue.main.sync {
                self.didLoadAtoms = true
            }
        }
    }
    
    func resetRenderer() {
        didLoadAtoms = false
        stringStep = "1"
        selectedAtoms.removeAll()
    }
    
    func moveNodes(toStep currentStep: Step) {
        for (i, atomNode) in atomNodes.childNodes.enumerated() {
            atomNode.position = currentStep.molecule!.atoms[i].position
        }
        updateBonds()
    }

    func updateBonds() {
        scene.rootNode.childNode(withName: "bonds", recursively: false)?.removeFromParentNode()
        bondNodes = SCNNode()
        bondNodes.name = "bonds"
        for i in atomNodes.childNodes.indices {
            checkBondingBasedOnDistance(nodeIndex: i, nodes: atomNodes)
        }
        scene.rootNode.addChildNode(bondNodes)
    }
    
    ///MARK: Setup scene function
    func setupScene(step: Step) {
    
        guard let molecule = step.molecule else {return}

        for (i,atom) in molecule.atoms.enumerated() {
            
            let newAtom = SCNAtomNode()
            newAtom.geometry = allGeometries.allAtomGeometries[atom.type]
            newAtom.name = "atom_\(atom.type.rawValue)"
            newAtom.position = atom.position
            newAtom.name?.append("_\(atom.number)")
            newAtom.castsShadow = false
            
            atomNodes.addChildNode(newAtom)
            checkBondingBasedOnDistance(atomIndex: i, molecule: molecule)
        }
        
        //Cylinders cause a significant drop in performance.If more than 1000 bonds are present. They become a flattened cone. The downside of this is that they are converted to a big node hence individual bonds cannot be broken
        if bondNodes.childNodes.count > 1000 {
            bondNodes = bondNodes.flattenedClone()
        }
        
        bondNodes.name = "bonds"

    }
    
    func backBonds(molecule: Molecule) {
        for i in 0..<molecule.atoms.endIndex - 1 {
            let pos1 = molecule.atoms[i].position
            let pos2 = molecule.atoms[i+1].position
            bondNodes.addChildNode(lineBetweenNodes(positionA: pos1, positionB: pos2, radius: 0.3))
        }
    }
    
    func bondSelectedAtoms() {
        if selectedAtoms.count == 2 {
            let atom1 = selectedAtoms[0].atom
            let atom2 = selectedAtoms[1].atom
            let position1 = atom1.position
            let position2 = atom2.position
            let bonds = lineBetweenNodes(positionA: position1, positionB: position2)
            bondNodes.addChildNode(bonds)
            
        }
    }
    
    func eraseSelectedAtoms() {
        for atom in selectedAtoms {
            atom.atom.removeFromParentNode()
            atom.orb.removeFromParentNode()
        }
        selectedAtoms.removeAll()
    }
    
    private func checkBondingBasedOnDistance(atomIndex: Int, molecule: Molecule) {
        var endIndex = atomIndex + 8

        if endIndex > molecule.atoms.count - 1 {
            endIndex = molecule.atoms.count - 1
        }
        
        let pos1 = molecule.atoms[atomIndex].position
        for i in atomIndex..<endIndex {
            let pos2 = molecule.atoms[i].position
            let x = (pos1.x - pos2.x)
            let y = (pos1.y - pos2.y)
            let z = (pos1.z - pos2.z)
            let distance = sqrt(x*x+y*y+z*z)
            if distance <= 1.54 && distance > 0.1 {
                bondNodes.addChildNode(lineBetweenNodes(positionA: pos1, positionB: pos2))
            }
        }
    }
    
    private func checkBondingBasedOnDistance(nodeIndex: Int, nodes: SCNNode) {
        var endIndex = nodeIndex + 50
        
        if endIndex > nodes.childNodes.count - 1 {
            endIndex = nodes.childNodes.count - 1
        }
        
        let pos1 = nodes.childNodes[nodeIndex].position
        for i in nodeIndex...endIndex {
            let pos2 = nodes.childNodes[i].position
            let distance = distance(from: pos1, to: pos2)
            if distance <= 1.50 && distance > 0.1 {
                bondNodes.addChildNode(lineBetweenNodes(positionA: pos1, positionB: pos2))
            }
        }
    }
    
    private func lineBetweenNodes(positionA: SCNVector3, positionB: SCNVector3, radius: Double = 0.2) -> SCNNode {
        let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)
        
        let lineGeometry = SCNCylinder()
        lineGeometry.radius = 0.1
        lineGeometry.materials = [allGeometries.material]
        lineGeometry.firstMaterial!.diffuse.contents = RColor(ColorSettings.shared.bondColor)
        lineGeometry.firstMaterial!.lightingModel = .physicallyBased
        lineGeometry.height = distance(from: positionA, to: positionB)
        
        let bondNode = SCNNode(geometry: lineGeometry)
        bondNode.name = "bond"
        bondNode.castsShadow = false
        
        bondNode.position = midPosition
        bondNode.look(at: positionB, up: scene.rootNode.worldUp, localFront: bondNode.worldUp)
        
        return bondNode
        
    }
}

class AtomRenderer: NSObject, SCNSceneRendererDelegate {
    
    @ObservedObject var controller: RendererController
        
    var selectedAtom: Element {PeriodicTableViewController.shared.selectedAtom}
    
    var selected1Tool: mainTools {ToolsController.shared.selected1Tool}
    
    var selected2Tool: editTools {ToolsController.shared.selected2Tool}
    
    var touch1:SCNVector3?
    
    var touch2:SCNVector3?
    
    var world0: SCNVector3 { controller.sceneView.projectPoint(SCNVector3Zero) }
    
    init(_ sceneView: SceneUI, controller: RendererController) {
        self.controller = controller
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //TODO: Implement light movement with camera
    }
    
    #warning("TODO: Clean up handleTaps")
    @objc func handleTaps(gesture: TapGesture) {
        
        let location = gesture.location(in: controller.sceneView)
        
        switch selected2Tool {
        case .addAtom:
            var count = 0
            if let molecule = controller.showingStep.molecule {
                count = molecule.atoms.count
            } else {
                controller.showingStep.molecule = Molecule()
            }
            let position = SCNVector3(location.x, location.y, CGFloat(world0.z))
            let unprojected = controller.sceneView.unprojectPoint(position)
            let atom = Atom(position: unprojected, type: selectedAtom, number: count + 1)
            controller.showingStep.molecule!.atoms.append(atom)
            controller.newAtom(atom: atom)
        case .removeAtom:
            let hitResult = controller.sceneView.hitTest(location).first
            guard let hitNode = hitResult?.node else {return}
            if hitNode.name == "selection" {
                guard let i = controller.selectedAtoms.firstIndex(where: {$0.orb == hitNode}) else {return}
                controller.selectedAtoms[i].atom.removeFromParentNode()
                controller.selectedAtoms[i].orb.removeFromParentNode()
                controller.selectedAtoms.remove(at: i)
            }
            hitNode.removeFromParentNode()
        case .selectAtom:
            let hitResult = controller.sceneView.hitTest(location).first
            if let hitNode = hitResult?.node {
                guard let name = hitNode.name else {return}
                if name.contains("atom") {
                    let atomOrbSelection = SCNNode()
                    atomOrbSelection.position = hitNode.position
                    
                    let selectionOrb = SCNSphere()
                    
                    selectionOrb.radius = CGFloat(hitNode.geometry!.boundingSphere.radius + 0.1)
                    
                    let selectionMaterial = SCNMaterial()
                    
                    selectionMaterial.diffuse.contents = RColor.systemBlue
                    
                    
                    selectionOrb.materials = [selectionMaterial]
                    
                    atomOrbSelection.name = "selection"
                    atomOrbSelection.geometry = selectionOrb
                    
                    atomOrbSelection.opacity = 0.35
                    controller.sceneView.scene?.rootNode.addChildNode(atomOrbSelection)
                    
                    controller.selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
                    controller.sceneView.defaultCameraController.target = hitNode.position
                    break
                }
                if hitNode.name == "selection"  {
                    guard let i = controller.selectedAtoms.firstIndex(where: {$0.orb == hitNode}) else {return}
                    controller.selectedAtoms.remove(at: i)
                    hitNode.removeFromParentNode()
                    break
                }
                if hitNode.name == "bond" {
                    
                    let material = SCNMaterial()
                    material.lightingModel = .physicallyBased
                    material.metalness.contents = 0.4
                    material.roughness.contents = 0.5
                    
                    let lineGeometry = hitNode.geometry?.copy() as! SCNGeometry
                    
                    let bondSelection = SCNNode(geometry: lineGeometry)
                    bondSelection.name = "bond"
                    bondSelection.castsShadow = false
                    
                    bondSelection.orientation = hitNode.orientation
                    
                    bondSelection.position = hitNode.position
                    
                    bondSelection.scale = SCNVector3Make(1.1, 1.1, 1.1)
                    
                    let selectionMaterial = SCNMaterial()
                    
                    selectionMaterial.diffuse.contents = RColor.systemBlue
                    selectionMaterial.transparency = 0.35
                    
                    bondSelection.geometry?.materials = [selectionMaterial]
                    
                    bondSelection.name = "selection"

                    controller.sceneView.scene?.rootNode.addChildNode(bondSelection)
                    
                    controller.selectedAtoms.append((atom: hitNode, orb: bondSelection))
                    break
                }

            }
            else {
                controller.selectedAtoms.removeAll()
                controller.sceneView.scene?.rootNode.childNodes.filter({ $0.name == "selection" }).forEach({ $0.removeFromParentNode() })

            }
        }
        
    }
    

}

class SCNAtomNode: SCNNode {
    var atomType: Element!
}

#warning("TODO: Explore in detail Geometries and making them available for the editor also")
#warning("TODO: 3D structures for folded proteins: Helix, Beta-sheet, turns...")
struct AllGeometries {
    
    static let shared = AllGeometries()
    
    let allAtomGeometries: [Element : SCNSphere]
    let material: SCNMaterial
    
    init() {
        
        var allAtomGeometries: [Element : SCNSphere] = [:]
        
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.4
        material.roughness.contents = 0.5
        
        self.material = material
        
        for atom in Element.allCases {
            let atomMaterial = material.copy() as! SCNMaterial
            atomMaterial.diffuse.contents = RColor(ColorSettings.shared.atomColors[atom.atomicNumber - 1])
            let sphere = SCNSphere(radius: atom.radius)
            sphere.materials = [atomMaterial]
            allAtomGeometries[atom] = sphere
        }
        
        self.allAtomGeometries = allAtomGeometries
    }
}
