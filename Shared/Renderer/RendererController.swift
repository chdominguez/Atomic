//
//  SharedRenderer.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/12/21.
//
import SwiftUI
import SceneKit

/// Controls the SceneKit SCNView. Renders the 3D atoms, bonds, handles tap gestures...
class RendererController: ObservableObject {
    
    //MARK: Init
    
    private let settings = GlobalSettings.shared
    
    /// The steps to display
    let steps: [Step]
    
    /// The current step showed
    var showingStep: Step {
        steps[stepToShow - 1]
    }
    
    init(_ steps: [Step]) {
        self.steps = steps
    }
    
    //MARK: Step control
    
    /// For moving the steps in sequential order
    private var timer = Timer()
    
    @Published var isPlaying = false
    @Published var playBack = 25
    @Published var stepToShow = 1 {
        didSet {
            moveNodes(toStep: steps[stepToShow - 1])
        }
    }
    
    /// Pauses or plays the movmenet of the atoms. Uses a Timer in order to move the atoms.
    func playAnimation() {
        if isPlaying {timer.invalidate()} // Stop the timer
        else { // Start the timer
            timer = Timer.scheduledTimer(withTimeInterval: 1/Double(playBack), repeats: true) { _ in
                self.nextScene()
            }
        }
        isPlaying.toggle() // Togle the isPlaying property to update the playing button shown in the view.
    }
    
    /// Changes the step to show to the next one
    func nextScene() {
        if stepToShow == steps.count {
            stepToShow = 1
        }
        else {
            stepToShow += 1
        }
    }
    
    /// Changes the step to show to the previous one
    func previousScene() {
        if stepToShow == 1 {
            stepToShow = steps.count
        }
        else {
            stepToShow -= 1
        }
    }
    
    //MARK: Scene
    
    /// Geometries for the nodes
    private let nodeGeom = NodeGeometries()
    
    var atomNodes = SCNNode()
    var bondNodes = SCNNode()
    var backBone = SCNNode()
    //var cartoonNodes = SCNNode() TODO: implement cartoon
    var selectionNodes = SCNNode()
    
    // SceneKit classes
    let sceneView = SCNView()
    let scene = SCNScene()
    let cameraNode = SCNNode()
    
    /// An array of tuples. The atoms selected with its selection orb node.
    var selectedAtoms: [(atom: SCNNode, orb: SCNNode)] = []
    
    /// Turns to true when loadScenes() has finished
    @Published var didLoadAtoms = false
    
    
    /// Loads the first step and places the child nodes in the scene
    func loadScenes() {
        guard let firstStep = steps.first else {fatalError("Here a step should be present")}
        if firstStep.molecule == nil { // in case we start with a new file
            firstStep.molecule = Molecule()
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            setupScene(firstStep)
            DispatchQueue.main.sync {
                didLoadAtoms = true
            }
        }
    }
    
    /// Maybe this function is not needed...
    func resetRenderer() {
        didLoadAtoms = false
        stepToShow = 1
        selectedAtoms.removeAll()
    }
    
    /// Animate the atoms and move them from one position to another
    private func moveNodes(toStep currentStep: Step) {
        for (i, atomNode) in atomNodes.childNodes.enumerated() {
            atomNode.position = currentStep.molecule!.atoms[i].position
        }
        // Slow movement for animatios if there are too much bonds to compute. Therefore better to not show onl for the first step
        if currentStep.molecule!.atoms.count < 500 {
            updateBonds()
        } else {
            if currentStep.stepNumber == 1 {
                scene.rootNode.addChildNode(bondNodes)
            } else {
                bondNodes.removeFromParentNode()
            }
        }
    }
    
    /// Recompute the bonds by checking the distance between adjacent atoms
    private func updateBonds() {
        //TODO: Find a way to also move the bonds for nicer animations, if that's possible
        bondNodes.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        for i in atomNodes.childNodes.indices {
            checkBondingBasedOnDistance(nodeIndex: i)
        }
    }
    
    //MARK: Setup scene
    
    /// Populates the SCNodes with atoms and bonds from the step molecule
    private func setupScene(_ step: Step) {
        
        guard let molecule = step.molecule else {return}
        
        atomNodes.name = "atoms"
        bondNodes.name = "bonds"
        backBone.name = "backBone"
        
        for atom in molecule.atoms {
            atomNodes.addChildNode(newAtom(atom))
            checkBondingBasedOnDistance(nodeIndex: atomNodes.childNodes.endIndex - 1) // Check bonding between the adjacent atoms
        }
        
        // Add the newly created atomNodes to the root scene
        scene.rootNode.addChildNode(atomNodes)
        
        // Cylinders cause a significant drop in performance.If more than 1000 bonds are present. They become a flattened cone. The downside of this is that they are converted to a big node hence individual bonds cannot be broken
        if bondNodes.childNodes.count > 1000 {
            self.bondNodes = bondNodes.flattenedClone()
        }
        
        scene.rootNode.addChildNode(bondNodes)
        
        // Compute the backbone for proteins
        if let backBone = step.backBone { backBonds(backBone) }
        
        // Add selection node as child of the main node
        
        scene.rootNode.addChildNode(selectionNodes)
        
    }
    
    private func newAtom(_ atom: Atom) -> SCNAtomNode {
        
        let atomNode = SCNAtomNode()
        
        atomNode.position = atom.position
        atomNode.atomType = atom.type
        atomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        atomNode.geometry = nodeGeom.atoms[atom.type]
        
        atomNode.constraints = [SCNBillboardConstraint()]
        atomNode.name = "atom_\(atom.type.rawValue)"
        
        return atomNode
    }
    
    private func backBonds(_ molecule: Molecule) {
        for i in 0..<molecule.atoms.endIndex - 1 {
            let pos1 = molecule.atoms[i].position
            let pos2 = molecule.atoms[i+1].position
            backBone.addChildNode(createBondNode(from: pos1, to: pos2, radius: 0.3))
        }
        //TODO: Implement backbone visibility based on default settings
        backBone.isHidden = true
        scene.rootNode.addChildNode(backBone)
    }
    
    /// Adds a bond node to bondNodes checking the distance between thgiven atom and the following 8 atoms (in list order) in the molecule.
    /// - Parameters:
    ///   - nodeIndex: The index of the atom node to bond
    private func checkBondingBasedOnDistance(nodeIndex endIndex: Int) {
        var firstIndex = endIndex - 8
        
        if firstIndex < 0 {
            firstIndex = 0
        }
        
        let pos1 = atomNodes.childNodes[endIndex].position
        for i in firstIndex...endIndex {
            let pos2 = atomNodes.childNodes[i].position
            let distance = distance(from: pos1, to: pos2)
            if distance <= 1.54 && distance > 0.1 {
                let newBond = createBondNode(from: pos1, to: pos2)
                bondNodes.addChildNode(newBond)
            }
        }
    }
    
    /// Creates a bond node between the given positions with a default radius of 0.2
    private func createBondNode(from positionA: SCNVector3, to positionB: SCNVector3, radius: Double = 0.2) -> SCNNode {
        
        let midPosition = SCNVector3Make((positionA.x + positionB.x) / 2,(positionA.y + positionB.y) / 2,(positionA.z + positionB.z) / 2)
        
        let bondGeometry = nodeGeom.bond!.copy() as! SCNCylinder
        bondGeometry.height = distance(from: positionA, to: positionB)
        
        let bondNode = SCNNode(geometry: bondGeometry)
        bondNode.name = "bond"
        
        bondNode.position = midPosition
        bondNode.look(at: positionB, up: scene.rootNode.worldUp, localFront: bondNode.worldUp)
        
        return bondNode
        
    }
    
    /// Creates a custom bond between two selected atoms
    func bondSelectedAtoms() {
        if selectedAtoms.count == 2 { // If more or less than 2 atoms selected, do nothing
            let position1 = selectedAtoms[0].atom.position
            let position2 = selectedAtoms[1].atom.position
            let bonds = createBondNode(from: position1, to: position2)
            bondNodes.addChildNode(bonds)
        }
    }
    
    /// Removes the selected atoms from the scene and from the selectedAtoms array
    func eraseSelectedAtoms() {
        for atom in selectedAtoms {
            atom.atom.removeFromParentNode()
            atom.orb.removeFromParentNode()
        }
        selectedAtoms.removeAll()
    }
    
    //MARK: Scene renderer controller
    
    private var selectedAtom: Element {PeriodicTableViewController.shared.selectedAtom}
    
    private var world0: SCNVector3 { sceneView.projectPoint(SCNVector3Zero) }
    
#warning("TODO: Clean up handleTaps")
    @objc func handleTaps(gesture: Gesture) {
        
        let location = gesture.location(in: sceneView)
        guard let molecule = showingStep.molecule else {return}
        
        switch ToolsController.shared.selectedTool {
        case .addAtom:
            newAtomOnTouch(molecule: molecule, at: location)
        case .selectAtom:
            selectAtomsOnTouch(at: location)
        default: return
            //                case .removeAtom:
            //                    let hitResult = controller.sceneView.hitTest(location).first
            //                    guard let hitNode = hitResult?.node else {return}
            //                    if hitNode.name == "selection" {
            //                        guard let i = controller.selectedAtoms.firstIndex(where: {$0.orb == hitNode}) else {return}
            //                        controller.selectedAtoms[i].atom.removeFromParentNode()
            //                        controller.selectedAtoms[i].orb.removeFromParentNode()
            //                        controller.selectedAtoms.remove(at: i)
            //                    }
            //                    hitNode.removeFromParentNode()
            //                case .selectAtom:
            //                    let hitResult = controller.sceneView.hitTest(location).first
            //                    if let hitNode = hitResult?.node {
            //                        guard let name = hitNode.name else {return}
            //                        if name.contains("atom") {
            //                            let atomOrbSelection = SCNNode()
            //                            atomOrbSelection.position = hitNode.position
            //
            //                            let selectionOrb = SCNSphere()
            //
            //                            selectionOrb.radius = CGFloat(hitNode.geometry!.boundingSphere.radius + 0.1)
            //
            //                            let selectionMaterial = SCNMaterial()
            //
            //                            selectionMaterial.diffuse.contents = UColor.systemBlue
            //
            //
            //                            selectionOrb.materials = [selectionMaterial]
            //
            //                            atomOrbSelection.name = "selection"
            //                            atomOrbSelection.geometry = selectionOrb
            //
            //                            atomOrbSelection.opacity = 0.35
            //                            controller.sceneView.scene?.rootNode.addChildNode(atomOrbSelection)
            //
            //                            controller.selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
            //                            controller.sceneView.defaultCameraController.target = hitNode.position
            //                            break
            //                        }
            //                        if hitNode.name == "selection"  {
            //                            guard let i = controller.selectedAtoms.firstIndex(where: {$0.orb == hitNode}) else {return}
            //                            controller.selectedAtoms.remove(at: i)
            //                            hitNode.removeFromParentNode()
            //                            break
            //                        }
            //                        if hitNode.name == "bond" {
            //
            //                            let material = SCNMaterial()
            //                            material.lightingModel = .physicallyBased
            //                            material.metalness.contents = 0.4
            //                            material.roughness.contents = 0.5
            //
            //                            let lineGeometry = hitNode.geometry?.copy() as! SCNGeometry
            //
            //                            let bondSelection = SCNNode(geometry: lineGeometry)
            //                            bondSelection.name = "bond"
            //                            bondSelection.castsShadow = false
            //
            //                            bondSelection.orientation = hitNode.orientation
            //
            //                            bondSelection.position = hitNode.position
            //
            //                            bondSelection.scale = SCNVector3Make(1.1, 1.1, 1.1)
            //
            //                            let selectionMaterial = SCNMaterial()
            //
            //                            selectionMaterial.diffuse.contents = UColor.systemBlue
            //                            selectionMaterial.transparency = 0.35
            //
            //                            bondSelection.geometry?.materials = [selectionMaterial]
            //
            //                            bondSelection.name = "selection"
            //
            //                            controller.sceneView.scene?.rootNode.addChildNode(bondSelection)
            //
            //                            controller.selectedAtoms.append((atom: hitNode, orb: bondSelection))
            //                            break
            //                        }
            //
            //                    }
            //                    else {
            //                        controller.selectedAtoms.removeAll()
            //                        controller.sceneView.scene?.rootNode.childNodes.filter({ $0.name == "selection" }).forEach({ $0.removeFromParentNode() })
            //
            //                    }
        }
        
    }
    
    private func newAtomOnTouch(molecule: Molecule, at location: CGPoint) {
        let position = SCNVector3(location.x, location.y, CGFloat(world0.z))
        let unprojected = sceneView.unprojectPoint(position)
        let atom = Atom(position: unprojected, type: selectedAtom, number: molecule.atoms.count + 1)
        molecule.atoms.append(atom)
        atomNodes.addChildNode(newAtom(atom))
    }
    
    private func selectAtomsOnTouch(at location: CGPoint) {
        
        let hitResult = sceneView.hitTest(location).first
        guard let hitNode = hitResult?.node else {removeSelectionOrbs(); return}
        guard let name = hitNode.name else {return}
        
        if name.contains("atom") {
            selectionAtomNode(hitNode: hitNode)
            return
        }
        if hitNode.name == "selection"  {
//            guard let i = controller.selectedAtoms.firstIndex(where: {$0.orb == hitNode}) else {return}
//            controller.selectedAtoms.remove(at: i)
//            hitNode.removeFromParentNode()
//            break
        }
        if hitNode.name == "bond" {
//
//            let material = SCNMaterial()
//            material.lightingModel = .physicallyBased
//            material.metalness.contents = 0.4
//            material.roughness.contents = 0.5
//
//            let lineGeometry = hitNode.geometry?.copy() as! SCNGeometry
//
//            let bondSelection = SCNNode(geometry: lineGeometry)
//            bondSelection.name = "bond"
//            bondSelection.castsShadow = false
//
//            bondSelection.orientation = hitNode.orientation
//
//            bondSelection.position = hitNode.position
//
//            bondSelection.scale = SCNVector3Make(1.1, 1.1, 1.1)
//
//            let selectionMaterial = SCNMaterial()
//
//            selectionMaterial.diffuse.contents = UColor.systemBlue
//            selectionMaterial.transparency = 0.35
//
//            bondSelection.geometry?.materials = [selectionMaterial]
//
//            bondSelection.name = "selection"
//
//            controller.sceneView.scene?.rootNode.addChildNode(bondSelection)
//
//            controller.selectedAtoms.append((atom: hitNode, orb: bondSelection))
//            break
        }
        
    }
    
    private func selectionAtomNode(hitNode: SCNNode) {
        
        let atomOrbSelection = hitNode.copy() as! SCNNode
        atomOrbSelection.geometry = atomOrbSelection.geometry?.copy() as! SCNSphere
        atomOrbSelection.scale = SCNVector3Make(1.2, 1.2, 1.2)
        atomOrbSelection.geometry?.materials = [settings.colorSettings.selectionMaterial]
        atomOrbSelection.name = "selection"
        atomOrbSelection.opacity = 0.35
        
        selectionNodes.addChildNode(atomOrbSelection)
        selectedAtoms.append((atom: hitNode, orb: atomOrbSelection))
        sceneView.defaultCameraController.target = hitNode.position
        
        print("Placed new sphere")
    }
    
    private func selectionBondNode() {
        
    }
    
    private func removeSelectionOrbs() {
        selectedAtoms.removeAll()
        selectionNodes.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
    }
    
}

class SCNAtomNode: SCNNode {
    var atomType: Element!
}
