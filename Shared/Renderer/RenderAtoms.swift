//
//  RenderAtoms.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/8/22.
//

import ProteinKit

extension MoleculeRenderer {
    internal func newAtom(_ atom: Atom) -> SCNNode {
        
        let atomNode = SCNNode()
        
        atomNode.position = atom.position
        atomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        atomNode.geometry = geometries.atoms[atom.type]
        
        atomNode.constraints = [SCNBillboardConstraint()]
        atomNode.name = "atom_\(atom.type.rawValue)"
        
        return atomNode
    }
    
    internal func loadCartoon(_ residues: [Residue]) {
        let pNode = ProteinKit(residues: residues)
        
        do {
            let n = try pNode.getProteinNode()
            cartoonNodes.addChildNode(n)
            atomicRootNode.addChildNode(cartoonNodes)
        } catch {
            fatalError("Bad PDB in ProteinKit")
        }
    }
    
    /// Adds a bond node to bondNodes checking the distance between thgiven atom and the following 8 atoms (in list order) in the molecule.
    /// - Parameters:
    ///   - nodeIndex: The index of the atom node to bond
    internal func checkBondingBasedOnDistance(nodeIndex endIndex: Int) {
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
    internal func createBondNode(from positionA: SCNVector3, to positionB: SCNVector3, type: BondType = .single, radius: Double = 0.1) {
        
        let midPosition = SCNVector3Make((positionA.x + positionB.x) / 2,(positionA.y + positionB.y) / 2,(positionA.z + positionB.z) / 2)
        
        let bondGeometry = geometries.bond!.copy() as! SCNCylinder
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
    
    /// Animate the atoms and move them from one position to another
    internal func moveNodes(toStep currentStep: Step) {
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
    internal func updateBonds() {
        //TODO: Find a way to also move the bonds for nicer animations, if that's possible
        bondNodes.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        for i in atomNodes.childNodes.indices {
            checkBondingBasedOnDistance(nodeIndex: i)
        }
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
}
