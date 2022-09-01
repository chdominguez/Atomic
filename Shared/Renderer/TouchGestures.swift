//
//  Gestures.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/8/22.
//

import ProteinKit
import CoreGraphics

extension MoleculeRenderer {
    internal var selectedFromPtable: Element {PeriodicTableViewController.shared.selectedAtom}
    
    internal var world0: SCNVector3 { atomicRootNode.position }
    
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
    
    internal func newAtomOnTouch(molecule: Molecule, at location: CGPoint) {
        let unprojected0 = unprojectPoint(SCNVector3(location.x, location.y, 0.99))

                                        
        let position = atomNodes.convertPosition(unprojected0, from: scene!.rootNode)
        let atom = Atom(position: position, type: selectedFromPtable, number: molecule.atoms.count + 1)
        molecule.atoms.append(atom)
        let kit = ProteinKit()
        kit.atomNodes(atoms: [atom], to: atomNodes, hidden: false)
    }
    
    internal func eraseNode(molecule: Molecule, at location: CGPoint) {
        guard let hitNode = hitTest(location).first?.node else {return}
        guard let name = hitNode.name else {return}
        if name.contains("atom") {internalAtomDelete(hitNode: hitNode, molecule: molecule); return}
        if name.contains("selection") {unSelect(hitNode)}
        if name.contains("bond") {hitNode.removeFromParentNode()}
    }
    
    internal func internalAtomDelete(hitNode: SCNNode, molecule: Molecule) {
        hitNode.removeFromParentNode()
        molecule.atoms.removeAll { atom in
            hitNode.position == atom.position
        }
        updateBonds()
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
    internal func editDistance(_ newValue: Double) {
        
        let pos1 = selectedAtoms[0].selectedNode.position
        let pos2 = selectedAtoms[1].selectedNode.position
        let vector = (pos2 - pos1).normalized()
        
        let newPosition = pos1 + vector.scaled(by: newValue)
        
        selectedAtoms[1].selectedNode.position = newPosition
        selectedAtoms[1].selectionOrb.position = newPosition
    }
    
    /// If the user changes manually measured angle, the selected nodes are updated to reflect the change.
    internal func editAngle(_ newValue: Double) {
        
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
}
