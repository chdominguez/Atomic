//
//  SharedRenderer.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/12/21.
//
import SwiftUI
import SceneKit
import SCNLine
import ProteinKit

class SRenderer: SCNView {
    override func keyDown(with event: NSEvent) {
        print("Keydown")
    }
}

/// Controls the SceneKit SCNView. Renders the 3D atoms, bonds, handles tap gestures...
class MoleculeRenderer: SCNView, ObservableObject {
    
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
        super.init(frame: .zero, options: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Step control
    
    /// For moving the steps in sequential order
    private var timer = Timer()
    
    @Published var isStepPlaying = false
    @Published var playBack = 25
    @Published var stepToShow = 1 {
        didSet {
            moveNodes(toStep: steps[stepToShow - 1])
        }
    }
    
    /// Pauses or plays the movmenet of the atoms. Uses a Timer in order to move the atoms.
    func playAnimation() {
        if isStepPlaying {timer.invalidate()} // Stop the timer
        else { // Start the timer
            timer = Timer.scheduledTimer(withTimeInterval: 1/Double(playBack), repeats: true) { _ in
                self.nextScene()
            }
        }
        isStepPlaying.toggle() // Togle the isPlaying property to update the playing button shown in the view.
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
    var backBoneNode = SCNLineNode()
    var cartoonNodes = SCNNode()
    var selectionNodes = SCNNode()
    
    // SceneKit classes
    //let sceneView = SCNView()
    //let scene = SCNScene()
    let atomicNode = SCNNode()
    var cameraNode = SCNNode()
    let cameraOrbit = SCNNode()
    var lightNode = SCNNode()
    
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
                scene!.rootNode.addChildNode(bondNodes)
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
    
    //MARK: Hide selected
    func hideSelected() {
        for atom in selectedAtoms {
            atom.selectedNode.isHidden = true
            atom.selectionOrb.isHidden = true
        }
    }
    
    func showAll() {
        atomNodes.enumerateChildNodes { node, _ in
            node.isHidden = false
        }
    }
    
    //MARK: Change style
    func changeSelectedOrView(to: AtomStyle) {
        switch to {
        case .ballAndStick:
            bondNodes.isHidden = false
            atomNodes.isHidden = false
            scaleVdW(scale: 0.7)
            cartoonNodes.isHidden = true
        case .vanderwaals:
            scaleVdW(scale: 1)
            cartoonNodes.isHidden = true
        case .backBone:
            backBoneNode.isHidden = false
        case .cartoon:
            bondNodes.isHidden = true
            atomNodes.isHidden = true
            cartoonNodes.isHidden = false
        }
    }
    
    private func scaleVdW(scale: Double) {
        if selectedAtoms.isEmpty {
            atomNodes.enumerateChildNodes { node, _ in
                node.scale = SCNVector3(scale, scale, scale)
            }
            return
        }
        for atom in selectedAtoms {
            atom.selectedNode.scale = SCNVector3(scale, scale, scale)
        }
    }
    
    //MARK: Setup scene
    
    /// Populates the SCNodes with atoms and bonds from the step molecule
    private func setupScene(_ step: Step) {
        
        scene = SCNScene()
        scene!.rootNode.name = "RootNode"
        atomicNode.name = "Atomic node"
        
        scene!.rootNode.addChildNode(atomicNode)
        
        guard let molecule = step.molecule else {return}
        
        atomNodes.name = "atoms"
        bondNodes.name = "bonds"
        backBoneNode.name = "backBone"
        cartoonNodes.name = "cartoon"
        selectionNodes.name = "Selection node"
        
        for atom in molecule.atoms {
            atomNodes.addChildNode(newAtom(atom))
            checkBondingBasedOnDistance(nodeIndex: atomNodes.childNodes.endIndex - 1) // Check bonding between the adjacent atoms
        }
        
        // Add the newly created atomNodes to the root scene
        atomicNode.addChildNode(atomNodes)
        
        // Cylinders cause a significant drop in performance.If more than 1000 bonds are present. They become a flattened cone. The downside of this is that they are converted to a big node hence individual bonds cannot be broken
        if bondNodes.childNodes.count > 1000 {
            self.bondNodes = bondNodes.flattenedClone()
        }
        
        atomicNode.addChildNode(bondNodes)
        
        // Compute the backbone and cartoon nodes for proteins
        if let _ = step.backBone {
            loadCartoon(step.res)
        }
        
        // Add selection node as child of the main node
        
        atomicNode.addChildNode(selectionNodes)
        
    }
    
    private func newAtom(_ atom: Atom) -> SCNNode {
        
        let atomNode = SCNNode()
        
        atomNode.position = atom.position
        atomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        atomNode.geometry = nodeGeom.atoms[atom.type]
        
        atomNode.constraints = [SCNBillboardConstraint()]
        atomNode.name = "atom_\(atom.type.rawValue)"
        
        return atomNode
    }
    
//    private func cartoonBackbone(_ molecule: Molecule, aa: [Residue]) {
//
//        let pos = molecule.atoms.filter { $0.info == "C" }.map { $0.position } // Define positions for the C carbons in te aa
//
//        backBoneNode = SCNLineNode(with: pos, radius: 0.2, edges: 12, maxTurning: 12) // Generate a line node linking the C carbons
//        //TODO: Implement backbone visibility based on default settings
//        backBoneNode.lineMaterials = nodeGeom.bond.materials
//        backBoneNode.isHidden = true
//        scene.rootNode.addChildNode(backBoneNode)
//
//        // Render cartoon
//
//        internalCartoon(aa, cpos: pos)
//    }
    
    private func cartoonBackbone(_ molecule: Molecule, aa: [Residue]) {
//        #warning("Testing importing .stl meshes into scenekit")
//        let url = Bundle.main.url(forResource: "4hhb", withExtension: "scn")!
//
//        let reference = try! SCNScene(url: url)
//
//        let node = reference.rootNode.childNodes.first!
//
//        node.geometry!.materials = nodeGeom.atoms[.nitrogen]!.materials
//
//        node.flattenedClone()
//
//        node.scale = SCNVector3(x: 10, y: 10, z: 10)
//
//        atomNodes.addChildNode(node)
//
//        scene.rootNode.addChildNode(backBoneNode)
       
    }
    
    private func loadCartoon(_ residues: [Residue]) {
        let pNode = ProteinKit(residues: residues)
        
        do {
            let n = try pNode.getProteinNode()
            cartoonNodes.addChildNode(n)
            atomicNode.addChildNode(cartoonNodes)
        } catch {
            fatalError("Bad PDB in ProteinKit")
        }
    }
    
//    private func internalCartoon(_ residues: [Residue], cpos: [SCNVector3]) {
//
//        guard let firstRes = residues.first else {return}
//
//        var prevStruc: SecondaryStructure = firstRes.structure
//
//        var newCartoonPositions: [CartoonPositions] = []
//
//        var currentPositions = CartoonPositions()
//
//        if residues.count != cpos.count {
//            print("Not matching")
//            print("Residues: \(residues.count), cpos: \(cpos.count)")
//            #warning("TODO: Implement error handling")
//            return
//        }
//
//        for (i, r) in residues.enumerated() {
//
//            if prevStruc != r.structure {
//                currentPositions.positions.append(cpos[i])
//                currentPositions.structure = prevStruc
//                newCartoonPositions.append(currentPositions)
//                currentPositions = CartoonPositions()
//            }
//
//            currentPositions.positions.append(cpos[i])
//
//            prevStruc = r.structure
//        }
//
//        guard let lastPos = cpos.last else {return}
//
//        currentPositions.positions.append(lastPos)
//        currentPositions.structure = prevStruc
//        newCartoonPositions.append(currentPositions)
//        currentPositions = CartoonPositions()
//
//        for cart in newCartoonPositions {
//            let newCoil = SCNLineNode(with: cart.positions, radius: 0.2, edges: 12, maxTurning: 12)
//            let material = SCNMaterial()
//            newCoil.lineMaterials = [material]
//            switch cart.structure {
//            case .alphaHelix, .helix310, .phiHelix:
//                material.diffuse.contents = UColor.green
//            case .strand:
//                material.diffuse.contents = UColor.blue
//            case .bridge:
//                material.diffuse.contents = UColor.red
//            case .coil:
//                material.diffuse.contents = UColor.brown
//            case .turnI, .turnIp, .turnII, .turnIIp, .turnVIa, .turnVIb, .turnVIII, .turnIV, .turn:
//                material.diffuse.contents = UColor.yellow
//            case .GammaClassic, .GammaInv:
//                material.diffuse.contents = UColor.orange
//            }
//            cartoonNodes.addChildNode(newCoil)
//        }
//
//        scene.rootNode.addChildNode(cartoonNodes)
//    }
    
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
            if distance <= 1.47 && distance > 0.1 {
                createBondNode(from: pos1, to: pos2)
            }
        }
    }
    
    /// Creates a bond node between the given positions with a default radius of 0.2
    private func createBondNode(from positionA: SCNVector3, to positionB: SCNVector3, type: BondType = .single, radius: Double = 0.1) {
        
        let midPosition = SCNVector3Make((positionA.x + positionB.x) / 2,(positionA.y + positionB.y) / 2,(positionA.z + positionB.z) / 2)
        
        let bondGeometry = nodeGeom.bond!.copy() as! SCNCylinder
        bondGeometry.radius = radius
        bondGeometry.height = distance(from: positionA, to: positionB)
        
        let bondNode = SCNNode(geometry: bondGeometry)
        bondNode.name = "bond"
        
        switch type {
        case .single:
            bondNode.position = midPosition
            bondNode.look(at: positionB, up: scene!.rootNode.worldUp, localFront: bondNode.worldUp)
            bondNodes.addChildNode(bondNode)
        case .double:
            bondNode.position = midPosition
            bondNode.look(at: positionB, up: scene!.rootNode.worldUp, localFront: bondNode.worldUp)
            let secondBondNode = bondNode.copy() as? SCNNode
            secondBondNode?.position.z += 0.15
            bondNode.position.z -= 0.15
            bondNodes.addChildNode(bondNode)
            if let secondBondNode = secondBondNode {
                bondNodes.addChildNode(secondBondNode)
            }
        case .triple:
            bondNode.position = midPosition
            bondNode.look(at: positionB, up: scene!.rootNode.worldUp, localFront: bondNode.worldUp)
            
            let secondBondNode = bondNode.copy() as? SCNNode
            let thirdBondNode = bondNode.copy() as? SCNNode
            
            secondBondNode?.position.z += 0.2
            thirdBondNode?.position.z -= 0.2
            
            bondNodes.addChildNode(bondNode)
            
            if let secondBondNode = secondBondNode, let thirdBondNode = thirdBondNode {
                bondNodes.addChildNode(secondBondNode)
                bondNodes.addChildNode(thirdBondNode)
            }
        }
        
    }
    
    enum BondType: String {
        case single = "Single"
        case double = "Double"
        case triple = "Triple"
        
        var symbol: String {
            switch self {
            case .single:
                return "line.diagonal"
            case .double:
                return "equal"
            case .triple:
                return "line.3.horizontal"
            }
        }
        
    }
    
    @Published var currentBondType: BondType = .single
    
    /// Creates a custom bond between two selected atoms
    func bondSelectedAtoms() {
        // If more or less than 2 atoms selected, do nothing
        guard selectedAtoms.count == 2 else {return}
        
        let position1 = selectedAtoms[0].selectedNode.position
        let position2 = selectedAtoms[1].selectedNode.position
        
        switch currentBondType {
        case .single:
            createBondNode(from: position1, to: position2, type: .single)
        case .double:
            createBondNode(from: position1, to: position2, type: .double, radius: 0.08)
        case .triple:
            createBondNode(from: position1, to: position2, type: .triple, radius: 0.05)
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
    
    /// Shows Angstroms or degrees depending on the number of selected atoms
    var currentUnit: String = " Å"
    
    var maxRange: ClosedRange<Double> {
        if selectedAtoms.count == 3 {
            return 0.5...180
        }
        return 0.5...5
    }
    
    var bindingDoubleDistangle: Binding<Double> {
        Binding { [self] in
            filterStoD(measuredDistangle, maxValue: maxRange.upperBound, minValue: maxRange.lowerBound)
        } set: {self.measuredDistangle = $0.stringWith(3) + self.currentUnit; self.editDistanceOrAngle()}

    }
    
    /// Measures the distance or the angle between two and three selected nodes, respectively and depending on the selected nodes quantity.
    private func measureNodes() {
        if selectedAtoms.count == 2 {
            currentUnit = " Å"
            let pos1 = selectedAtoms[0].selectedNode.position
            let pos2 = selectedAtoms[1].selectedNode.position
            measuredDistangle = distance(from: pos1, to: pos2).stringWith(3) + currentUnit
            showDistangle = true
            return
            
        }
        
        if selectedAtoms.count == 3 {
            currentUnit = "º"
            let pos1 = selectedAtoms[0].selectedNode.position
            let pos2 = selectedAtoms[1].selectedNode.position
            let pos3 = selectedAtoms[2].selectedNode.position
            
            measuredDistangle = angle(pos1: pos1, pos2: pos2, pos3: pos3).stringWith(3) + currentUnit
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
    
    private var world0: SCNVector3 { pointOfView!.worldFront }
    
    @objc func handleTaps(gesture: TapGesture) {
        
        let location = gesture.location(in: self)
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
        let position = SCNVector3(location.x, location.y, -1)
        print(position)
        let unprojected = unprojectPoint(position)
        print(unprojected)
        let atom = Atom(position: unprojected, type: selectedFromPtable, number: molecule.atoms.count + 1)
        molecule.atoms.append(atom)
        atomNodes.addChildNode(newAtom(atom))
    }
    
    private func eraseNode(molecule: Molecule, at location: CGPoint) {
        guard let hitNode = hitTest(location).first?.node else {return}
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
        
        guard let hitNode = hitTest(location).first?.node else {unSelectAll();measureNodes(); return}
        guard let name = hitNode.name else {return}
        
        //cameraOrbit.position = hitNode.position
        
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
        
        #warning("TODO: Rotate around selected node")
        // So the node roation happens around the selected node
        //atomicNode.pivot = SCNMatrix4MakeTranslation(hitNode.position.x, hitNode.position.y, hitNode.position.z)
        //atomicNode.pivot = cameraOrbit.pivot
        //atomicNode.position = hitNode.position
        
        selectionNodes.addChildNode(atomOrbSelection)
        selectedAtoms.append((hitNode, atomOrbSelection))
        //defaultCameraController.target = hitNode.position
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
    
    //MARK: Camera controls
    
    func zoomCamera(_ inOrOut: Bool) {
        let proportion = cameraNode.position.z
        if inOrOut {
            cameraNode.runAction(SCNAction.move(to:cameraNode.position - SCNVector3(0,0,0.25*proportion), duration: 0.1))
        }
        else {
            cameraNode.runAction(SCNAction.move(to: cameraNode.position + SCNVector3(0,0,0.25*proportion), duration: 0.1))
        }
    }
    
    private var previousPanTranslation: NSPoint? = nil
    
    // Save code for rotate molecules etc...
    private func rotate(sender recognizer: NSPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .began:
            self.previousPanTranslation = .zero
        case .changed:
            guard let previous = self.previousPanTranslation else
            {
                assertionFailure("Attempt to unwrap previous pan translation failed.")
                return
            }
            // Calculate how much translation occurred between this step and the previous step
            let translation = recognizer.translation(in: self)
            let translationDelta = CGPoint(x: translation.x - previous.x, y: translation.y - previous.y)
            // Use the pan translation along the x axis to adjust the camera's rotation about the y axis.
            let yScalar = Float(translationDelta.x / self.bounds.size.width)
            let yRadians = yScalar * 2//* self.dynamicType.MaxPanGestureRotation
            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis.
            let xScalar = Float(translationDelta.y / self.bounds.size.height)
            let xRadians = xScalar * 2//* self.dynamicType.MaxPanGestureRotation
            // Use the radian values to construct quaternions
            let x = GLKQuaternionMakeWithAngleAndAxis(-xRadians, 1, 0, 0)
            let y = GLKQuaternionMakeWithAngleAndAxis(yRadians, 0, 1, 0)
            let z = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1)
            let combination = GLKQuaternionMultiply(z, GLKQuaternionMultiply(y, x))
            // Multiply the quaternions to obtain an updated orientation
            let scnOrientation = self.atomicNode.orientation
            let glkOrientation = GLKQuaternionMake(Float(scnOrientation.x), Float(scnOrientation.y), Float(scnOrientation.z), Float(scnOrientation.w))
            let q = GLKQuaternionMultiply(combination, glkOrientation)
            // And finally set the current orientation to the updated orientation
            self.atomicNode.orientation = SCNQuaternion(x: CGFloat(q.x), y: CGFloat(q.y), z: CGFloat(q.z), w: CGFloat(q.w))
            self.previousPanTranslation = translation
        case .ended, .cancelled, .failed:
            self.previousPanTranslation = nil
        default:
            break
        }
    }

    var previousLoc = CGPoint.init(x: 0, y: 0)
    private func moveCamera(sender: PanGesture) {
        var delta = sender.translation(in: self)
        let loc = sender.location(in: self)
        
        if sender.state == .changed {
            delta = CGPoint.init(x: 2 * (loc.x - previousLoc.x), y: 2 * (loc.y - previousLoc.y))
            atomicNode.position = SCNVector3(atomicNode.position.x + UFloat(delta.x * 0.02), atomicNode.position.y + UFloat(delta.y * (0.02)), 0)
            previousLoc = loc
        }
        previousLoc = loc
    }
    
    
    @objc func handlePan(sender: PanGesture) {
        if sender.buttonMask == 1 {
            moveCamera(sender: sender)
            return
        }
        if sender.buttonMask == 2 {
            rotate(sender: sender)
            return
        }
    }
    
    func resetPivot() {
        let positions = steps.first?.molecule?.atoms.map {$0.position}
        guard let positions = positions else {return}
        let nodePos = averageDistance(of: positions)
        let cameraPos = viewingZPosition(toSee: positions) + 10

        atomicNode.pivot = SCNMatrix4MakeTranslation(nodePos.x, nodePos.y, nodePos.z)
        let moveAction = SCNAction.move(to: .zero, duration: 0.2)
        let moveCamera = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: cameraPos), duration: 0.2)
        atomicNode.runAction(moveAction)
        cameraOrbit.runAction(moveAction)
        cameraNode.runAction(moveCamera)
    }
    
    func makeSelectedPivot() {
        guard let node = selectedAtoms.first?.selectedNode else {return}
        let newPos = node.position
        atomicNode.pivot = SCNMatrix4MakeTranslation(newPos.x, newPos.y, newPos.z)
        let moveAction = SCNAction.move(to: .zero, duration: 0.2)
        let moveCameraZoomTo0 = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 10), duration: 0.2)
        atomicNode.runAction(moveAction)
        cameraOrbit.runAction(moveAction)
        cameraNode.runAction(moveCameraZoomTo0)
    }
    
    private var optionPressed: Bool = false
    
#if os(macOS)
    override func flagsChanged(with event: NSEvent) {
        if event.keyCode == 58 {
            optionPressed.toggle()
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        if optionPressed {
            cameraNode.localTranslate(by: SCNVector3(x: 0, y: 0, z: event.scrollingDeltaY/50))
        }
        else {
            cameraOrbit.localTranslate(by: SCNVector3(x: 0, y: -event.scrollingDeltaY/50, z: 0))
            cameraOrbit.localTranslate(by: SCNVector3(x: event.scrollingDeltaX/50, y: 0, z: 0))
        }
    }
#endif
}

class AtomicCameraController: SCNCameraController {
    
}
