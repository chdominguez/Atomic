//
//  Renderercontroller_macOS.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 15/12/21.
//

import SwiftUI
import SceneKit


class RendererController: SharedRenderer, ObservableObject {
    
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
                    self.progress += progressStep
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
            material.diffuse.contents = NSColor(atom.type.color)
            
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
        lineGeometry.firstMaterial!.diffuse.contents = NSColor.lightGray
        
        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = midPosition
        lineNode.look(at: positionB, up: node.worldUp, localFront: lineNode.worldUp)
        lineNode.name = "bond"
        
        return lineNode
        
    }
}
