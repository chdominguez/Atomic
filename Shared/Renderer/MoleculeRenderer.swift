//
//  SharedRenderer.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/12/21.
//
import SwiftUI
import SceneKit

/// Controls the SceneKit SCNView. Renders the 3D atoms, bonds, handles tap gestures...
class MoleculeRenderer: ObservableObject {
    
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
    
    /// An array of tuples. The nodes selected with its selection orb node.
    @Published var selectedAtoms: [(selectedNode: SCNNode, selectionOrb: SCNNode)] = [] {
        didSet {
            withAnimation {
                measureNodes()
            }
        }
    }
    
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
            let position1 = selectedAtoms[0].selectedNode.position
            let position2 = selectedAtoms[1].selectedNode.position
            let bonds = createBondNode(from: position1, to: position2)
            bondNodes.addChildNode(bonds)
        }
    }
    
    /// Removes the selected atoms from the scene and from the selectedAtoms array
    func eraseSelectedAtoms() {
        for atom in selectedAtoms {
            atom.selectedNode.removeFromParentNode()
        }
        unSelectAll()
        updateBonds()
    }
    
    
    //MARK: Tools
    
    /// Available tools
    enum Tools {
        case addAtom
        case removeAtom
        case selectAtom
    }
    
    /// Selected tool on this scene
    @Published var selectedTool: Tools = .selectAtom
    
    /// Distance of selected nodes
    @Published var measuredDistangle: String = ""
    @Published var showDistangle: Bool = false
    
    var maxRange: ClosedRange<Double> {
        if selectedAtoms.count == 3 {
            return 0.5...180
        }
        return 0.5...5
    }
    
    var bindingDoubleDistangle: Binding<Double> {
        Binding { [self] in
            filterStoD(measuredDistangle, maxValue: maxRange.upperBound, minValue: maxRange.lowerBound)
        } set: {self.measuredDistangle = String($0); self.editDistanceOrAngle()}

    }
    
    /// Measures the distance or the angle between two and three selected nodes, respectively and depending on the selected nodes quantity.
    private func measureNodes() {
        if selectedAtoms.count == 2 {
            let pos1 = selectedAtoms[0].selectedNode.position
            let pos2 = selectedAtoms[1].selectedNode.position
            measuredDistangle = distance(from: pos1, to: pos2).stringWith(3) + " Å"
            showDistangle = true
            return
            
        }
        
        if selectedAtoms.count == 3 {
            let pos1 = selectedAtoms[0].selectedNode.position
            let pos2 = selectedAtoms[1].selectedNode.position
            let pos3 = selectedAtoms[2].selectedNode.position
            
            measuredDistangle = angle(pos1: pos1, pos2: pos2, pos3: pos3).stringWith(3) + "º"
            showDistangle = true
            return
        }
        
        // Fallthrough
        showDistangle = false
    }
    
    func editDistanceOrAngle() {
        
        if selectedAtoms.count == 2 {
            let newDistance = filterStoD(measuredDistangle, maxValue: .infinity, minValue: 0.5)
            editDistance(newDistance)
        }
        if selectedAtoms.count == 3 {
            let newAngle = filterStoD(measuredDistangle, maxValue: 180, minValue: 0.5)
            editAngle(newAngle)
        }
        updateBonds()
        //measureNodes()
    }
    
    /// If the user changes manually measured distance, the selected nodes are updated to reflect the change.
    private func editDistance(_ newValue: Double) {
        
        let pos1 = selectedAtoms[0].selectedNode.position
        let pos2 = selectedAtoms[1].selectedNode.position
        let vector = (pos2 - pos1).normalized()
        
        let newPosition = pos1 + vector.scaled(by: newValue)
        
        selectedAtoms[1].selectedNode.position = newPosition
        selectedAtoms[1].selectionOrb.position = newPosition
    }
    
    /// If the user changes manually measured angle, the selected nodes are updated to reflect the change.
    private func editAngle(_ newValue: Double) {
        
        let pos1 = selectedAtoms[0].selectedNode.position
        let pos2 = selectedAtoms[1].selectedNode.position
        let pos3 = selectedAtoms[2].selectedNode.position
        
        let vector1 = (pos1 - pos2)
        let vector2 = (pos3 - pos2)
        
        let newAngle = (newValue - angle(pos1: pos1, pos2: pos2, pos3: pos3)).toRadians()
        
        let normal = vector1.crossProduct(vector2).normalized()
        
        let newPos = pos2 + vector2.rotated(by: newAngle, withRespectTo: normal)
        
        selectedAtoms[2].selectedNode.position = newPos
        selectedAtoms[2].selectionOrb.position = newPos
    }
    
    
    //MARK: Scene renderer controller
    
    private var selectedFromPtable: Element {PeriodicTableViewController.shared.selectedAtom}
    
    private var world0: SCNVector3 { sceneView.projectPoint(SCNVector3Zero) }
    
    @objc func handleTaps(gesture: Gesture) {
        
        let location = gesture.location(in: sceneView)
        guard let molecule = showingStep.molecule else {return}
        
        switch selectedTool {
        case .addAtom:
            newAtomOnTouch(molecule: molecule, at: location)
        case .selectAtom:
            newSelection(at: location)
        case .removeAtom:
            eraseNode(molecule: molecule, at: location)
        }
    }
    
    private func newAtomOnTouch(molecule: Molecule, at location: CGPoint) {
        let position = SCNVector3(location.x, location.y, CGFloat(world0.z))
        let unprojected = sceneView.unprojectPoint(position)
        let atom = Atom(position: unprojected, type: selectedFromPtable, number: molecule.atoms.count + 1)
        molecule.atoms.append(atom)
        atomNodes.addChildNode(newAtom(atom))
    }
    
    private func eraseNode(molecule: Molecule, at location: CGPoint) {
        guard let hitNode = sceneView.hitTest(location).first?.node else {return}
        guard let name = hitNode.name else {return}
        if name.contains("atom") {internalAtomDelete(hitNode: hitNode, molecule: molecule); return}
        if name.contains("selection") {unSelect(hitNode)}
        if name.contains("bond") {hitNode.removeFromParentNode()}
    }
    
    private func internalAtomDelete(hitNode: SCNNode, molecule: Molecule) {
        hitNode.removeFromParentNode()
        molecule.atoms.removeAll { atom in
            hitNode.position == atom.position
        }
        updateBonds()
    }
    
    
    private func newSelection(at location: CGPoint) {
        
        guard let hitNode = sceneView.hitTest(location).first?.node else {unSelectAll();measureNodes(); return}
        guard let name = hitNode.name else {return}
        
        if name.contains("atom") {internalSelectionAtomNode(hitNode)}
        if hitNode.name == "bond" {internalSelectionBond(hitNode)}
        if hitNode.name == "selection" {unSelect(hitNode)}
        
        measureNodes()
    }
    
    private func internalSelectionAtomNode(_ hitNode: SCNNode) {
        let atomOrbSelection = hitNode.copy() as! SCNNode
        atomOrbSelection.geometry = atomOrbSelection.geometry?.copy() as! SCNSphere
        atomOrbSelection.scale = SCNVector3Make(1.2, 1.2, 1.2)
        atomOrbSelection.geometry?.materials = [settings.colorSettings.selectionMaterial]
        atomOrbSelection.name = "selection"
        atomOrbSelection.opacity = 0.35
        
        selectionNodes.addChildNode(atomOrbSelection)
        selectedAtoms.append((hitNode, atomOrbSelection))
        sceneView.defaultCameraController.target = hitNode.position
    }
    
    private func internalSelectionBond(_ hitNode: SCNNode) {
        let bondOrbSelection = hitNode.copy() as! SCNNode
        bondOrbSelection.geometry = bondOrbSelection.geometry?.copy() as! SCNCylinder
        bondOrbSelection.scale = SCNVector3Make(1.2, 1, 1.2)
        bondOrbSelection.geometry?.materials = [settings.colorSettings.selectionMaterial]
        bondOrbSelection.name = "selection"
        bondOrbSelection.opacity = 0.35
        
        selectionNodes.addChildNode(bondOrbSelection)
        selectedAtoms.append((hitNode, bondOrbSelection))
        //Temporal adjusting camera's target to the selected bond. Future implementation: rotate the scene around the center of the view, as if an invisible atomwas present in front of the camera.
        sceneView.defaultCameraController.target = hitNode.position
    }
    
    /// Unselect the hitted selection
    private func unSelect(_ hitNode: SCNNode) {
        hitNode.removeFromParentNode()
        selectedAtoms.removeAll { $0.selectionOrb == hitNode }
    }
    
    /// Unselects all the selected nodes
    private func unSelectAll() {
        selectedAtoms.removeAll()
        selectionNodes.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
    }
    
}

class SCNAtomNode: SCNNode {
    var atomType: Element!
}
