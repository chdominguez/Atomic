//
//  SharedRenderer.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/12/21.
//
import SwiftUI
import SceneKit

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

class RendererController: ObservableObject {
    
    var timer = Timer()
    let steps: [Step]
    let allGeometries = AllGeometries()
    
    var atomNodes = SCNNode()
    var bondNodes = SCNNode()
    
    @Published var totalNodes = 0
    @Published var sceneView = SCNView()
    @Published var scene = SCNScene()

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
    @Published var stringStep = "1" {
        didSet {
            updateScene()
        }
    }
    
    
    init(_ steps: [Step]) {
        self.steps = steps
        self.showingStep = steps.first!
    }
    
    func newAtom(atom: Atom) {
        
        let atomNode = SCNAtomNode()
        
        let radius = atom.type.radius
        let sphere = SCNSphere(radius: radius)

        atomNode.atomType = atom.type
        atomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        let material = SCNMaterial()
        material.diffuse.contents = RColor(atom.type.color)
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
    }
    
    func updateScene() {
        let intScene = Int(stringStep)! - 1
        moveNodes(toStep: steps[intScene])
    }
    
    
    func loadScenes() {
        DispatchQueue.global(qos: .background).async { [self] in
            setupScene(step: steps.first!)
            DispatchQueue.main.sync {
                self.didLoadAtoms = true
                self.totalNodes = self.scene.rootNode.childNodes.count
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
            guard let position = currentStep.molecule?.atoms[i].position else {return}
            atomNode.position = position
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
    
    ///MARK: Setup scene function - Optimize
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
            #warning("TODO: Check bonding improvements. Mayble implement in C")
            //checkBondingBasedOnDistance(atomIndex: i, molecule: molecule)
            checkAllBondings()
            
        }
        atomNodes.name = "atoms"
        bondNodes.name = "bonds"
        //Cylinders cause a significant drop in performance for 10k atoms. Reducing it to only one node improves speed.
        bondNodes = bondNodes.flattenedClone()
        scene.rootNode.addChildNode(atomNodes)
        scene.rootNode.addChildNode(bondNodes)
        
        //atomsNodes = checkBondingBasedOnDistance(node: atomsNodes, molecule: molecule)
        
        
    }
    
    func bondSelectedAtoms() {
        if selectedAtoms.count == 2 {
            let atom1 = selectedAtoms[0].atom
            let atom2 = selectedAtoms[1].atom
            let position1 = atom1.position
            let position2 = atom2.position
            //let currentNode = atomChildNodes[selectedIndex]
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
    
    private func checkAllBondings()  {
        for node1 in atomNodes.childNodes {
            for node2 in atomNodes.childNodes {
                let x = (node1.position.x - node2.position.x)
                let y = (node1.position.y - node2.position.y)
                let z = (node1.position.z - node2.position.z)
                let distance = sqrt(x*x+y*y+z*z)
                if distance <= 1.53 && distance > 0.1 {
                    bondNodes.addChildNode(lineBetweenNodes(positionA: node1.position, positionB: node2.position))
                }
            }
        }
    }
    
    private func checkBondingBasedOnDistance(atomIndex: Int, molecule: Molecule) {
        var endIndex = atomIndex + 10
        
        if endIndex > molecule.atoms.count - 1 {
            endIndex = molecule.atoms.count - 1
        }
        
        let pos1 = molecule.atoms[atomIndex].position
        for i in atomIndex...endIndex {
            let pos2 = molecule.atoms[i].position
            let x = (pos1.x - pos2.x)
            let y = (pos1.y - pos2.y)
            let z = (pos1.z - pos2.z)
            let distance = sqrt(x*x+y*y+z*z)
            if distance <= 1.53 && distance > 0.1 {
                bondNodes.addChildNode(lineBetweenNodes(positionA: pos1, positionB: pos2))
            }
        }
    }
    
    private func checkBondingBasedOnDistance(nodeIndex: Int, nodes: SCNNode) {
        var endIndex = nodeIndex + 10
        
        if endIndex > nodes.childNodes.count - 1 {
            endIndex = nodes.childNodes.count - 1
        }
        
        let pos1 = nodes.childNodes[nodeIndex].position
        for i in nodeIndex...endIndex {
            let pos2 = nodes.childNodes[i].position
            let x = (pos1.x - pos2.x)
            let y = (pos1.y - pos2.y)
            let z = (pos1.z - pos2.z)
            let distance = sqrt(x*x+y*y+z*z)
            if distance <= 1.6 && distance > 0.1 {
                bondNodes.addChildNode(lineBetweenNodes(positionA: pos1, positionB: pos2))
            }
        }
    }
    
    private func lineBetweenNodes(positionA: SCNVector3, positionB: SCNVector3) -> SCNNode {
        //let vector = SCNVector3(positionA.x - positionB.x, positionA.y - positionB.y, positionA.z - positionB.z)
        //let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)
        
        let bondNode = SCNNode(geometry: self.allGeometries.singleBondGeom)
        bondNode.name = "bond"
        bondNode.castsShadow = false
        
        //bondNode.isHidden = true
        bondNode.position = midPosition
        bondNode.look(at: positionB, up: scene.rootNode.worldUp, localFront: bondNode.worldUp)
        
        return bondNode
        
    }
}

class AtomRenderer {
    
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
                    
                    selectionMaterial.diffuse.contents = Color.blue
                    
                    
                    selectionOrb.materials = [selectionMaterial]
                    
                    atomOrbSelection.name = "selection"
                    atomOrbSelection.geometry = selectionOrb
                    
                    atomOrbSelection.opacity = 0.3
                    controller.sceneView.scene?.rootNode.addChildNode(atomOrbSelection)
                    
                    controller.selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
                    break
                }
                if hitNode.name == "selection"  {
                    guard let i = controller.selectedAtoms.firstIndex(where: {$0.orb == hitNode}) else {return}
                    controller.selectedAtoms.remove(at: i)
                    hitNode.removeFromParentNode()
                    break
                }
                if hitNode.name == "bond" {
                    let atomOrbSelection = hitNode.copy() as! SCNNode
                    
                    let selectionMaterial = SCNMaterial()
                    
                    selectionMaterial.diffuse.contents = RColor(.cyan)
                    
                    atomOrbSelection.geometry?.materials = [selectionMaterial]
                    
                    atomOrbSelection.name = "selection"

                    controller.sceneView.scene?.rootNode.addChildNode(atomOrbSelection)
                    
                    controller.selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
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
struct AllGeometries {
    let allAtomGeometries: [Element : SCNSphere]
    //let allAtomGeometries: [Element : SCNBox]
    let singleBondGeom: SCNCylinder
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
            atomMaterial.diffuse.contents = RColor(atom.color)
            let sphere = SCNSphere(radius: atom.radius)
            sphere.materials = [atomMaterial]
            allAtomGeometries[atom] = sphere
            
        }
        
        let lineGeometry = SCNCylinder()
        lineGeometry.radius = 0.1
        lineGeometry.materials = [material.copy() as! SCNMaterial]
        lineGeometry.firstMaterial!.diffuse.contents = RColor.lightGray
        lineGeometry.firstMaterial!.lightingModel = .physicallyBased
        lineGeometry.height = 1.1
        
        self.singleBondGeom = lineGeometry
        
        self.allAtomGeometries = allAtomGeometries
    }
}
