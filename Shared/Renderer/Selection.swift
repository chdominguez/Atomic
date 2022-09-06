//
//  Selection.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/8/22.
//

import ProteinKit
import SwiftUI

extension MoleculeRenderer {
    internal func newSelection(at location: CGPoint) {
        
        guard let hitNode = hitTest(location).first?.node else {unSelectAll();measureNodes(); return}
        guard let name = hitNode.name else {return}
        
        if name.starts(with: "A") || name.starts(with: "C") {internalSelectionNode(hitNode)}
        if name.starts(with: "B") {internalSelectionBond(hitNode)}
        if name.starts(with: "S") {unSelect(hitNode)}
        
        measureNodes()
    }
    
    internal func internalSelectionNode(_ hitNode: SCNNode) {
        let center = hitNode.boundingSphere.center
        
        let selectionOrb = hitNode.clone()
        let copyGeo = selectionOrb.geometry!.copy() as! SCNGeometry
        copyGeo.materials = [settings.colorSettings.selectionMaterial]
        selectionOrb.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        
        if hitNode.name!.starts(with: "C") {selectionOrb.position = center}
        
        selectionOrb.geometry = copyGeo
        selectionOrb.opacity = 0.35
        selectionOrb.runAction(.scale(by: 1.2, duration: 0.08))
        selectionOrb.name = "S"
        selectionNodes.addChildNode(selectionOrb)
        selectedAtoms.append((hitNode, selectionOrb))
    }
    
    internal func internalSelectionBond(_ hitNode: SCNNode) {
        let bondOrbSelection = hitNode.copy() as! SCNNode
        bondOrbSelection.geometry = bondOrbSelection.geometry?.copy() as! SCNCylinder
        bondOrbSelection.scale = SCNVector3Make(1.2, 1, 1.2)
        bondOrbSelection.geometry?.materials = [settings.colorSettings.selectionMaterial]
        bondOrbSelection.name = "S"
        bondOrbSelection.opacity = 0.35
        
        selectionNodes.addChildNode(bondOrbSelection)
        selectedAtoms.append((hitNode, bondOrbSelection))
        //Temporal adjusting camera's target to the selected bond. Future implementation: rotate the scene around the center of the view, as if an invisible atomwas present in front of the camera.
    }
    
    /// Unselect the hitted selection
    internal func unSelect(_ hitNode: SCNNode) {
        hitNode.runAction(SCNAction.sequence([.scale(by: 0.5, duration: 0.2), .removeFromParentNode()]))
        selectedAtoms.removeAll { $0.selectionOrb == hitNode }
    }
    
    /// Unselects all the selected nodes
    internal func unSelectAll() {
        selectedAtoms.removeAll()
        selectionNodes.enumerateChildNodes { node, _ in
            node.runAction(SCNAction.sequence([.scale(by: 0.5, duration: 0.2), .removeFromParentNode()]))
        }
    }
    
    /// Measures the distance or the angle between two and three selected nodes, respectively and depending on the selected nodes quantity.
    internal func measureNodes() {
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
    
    /// Selects an entire node
    /// - Parameter node: The node to be selected
    func selectFullmolecule(node: SCNNode) {
        node.enumerateChildNodes { child, _ in
            if !child.isHidden {
                let selectionNode = child.flattenedClone()
                
                selectionNode.geometry?.materials = [settings.colorSettings.selectionMaterial]
                selectionNode.name = "selection"
                selectionNode.scale = SCNVector3(x: 1.2, y: 1.2, z: 1.2)
                selectionNode.opacity = 0.35
                
                let cloned = child.flattenedClone()
                cloned.position = selectionNode.position * 2
                cloned.geometry?.materials = geometries.atoms[.fluorine]!.materials
                
                selectionNode.addChildNode(cloned)
                selectionNodes.addChildNode(selectionNode)
                selectedAtoms.append((child, selectionNode))
                
            }
        }
        
        let atomzero = SCNNode(geometry: SCNSphere(radius: 1))
        selectionNodes.addChildNode(atomzero)
        let atom2 = SCNNode(geometry: SCNSphere(radius: 1))
        atom2.geometry = geometries.atoms[.oxygen]
        atomNodes.addChildNode(atom2)
        //sceneView.defaultCameraController.target = node.position
    }
    
    func newColorForSelection(newColor: Color, changeOfSameType: Bool, affectMolecules: Bool, types: AppearanceView.SelectionTypes) {
        if changeOfSameType {
            for sel in selectedAtoms {
                guard sel.selectedNode.name!.contains("_") else {break}
                let moleculeName = sel.selectedNode.name?.split(separator: "_")[3]
                let selectedStyle = sel.selectedNode.name?.split(separator: "_")[0]
                let selectedType = sel.selectedNode.name?.split(separator: "_")[1]
                
                if affectMolecules {
                    if selectedStyle == "A" {
                        atomNodes.enumerateChildNodes { atom, _ in
                            guard atom.name!.contains("_") else {return}
                            if atom.name?.split(separator: "_")[1] == selectedType {
                                atom.geometry?.materials.first?.diffuse.contents = newColor.uColor
                            }
                        }
                    }
                    if selectedStyle == "C" {
                        cartoonNodes.enumerateChildNodes { atom, _ in
                            guard atom.name!.contains("_") else {return}
                            if atom.name?.split(separator: "_")[1] == selectedType {
                                atom.geometry?.materials.first?.diffuse.contents = newColor.uColor
                            }
                        }
                    }
                } else {
                    if types == .structure {
                        guard let selectedStructure = sel.selectedNode.name?.split(separator: "_").last else {return}
                        var nodeName = "Helices"
                        
                        switch selectedStructure {
                        case "1":
                            nodeName = "Other"
                        case "2":
                            nodeName = "Helices"
                        case "3":
                            nodeName = "Sheets"
                        default: return
                            
                        }
                        cartoonNodes.enumerateChildNodes { node, _ in
                            if node.name == nodeName {
                                let clonedMaterial = sel.selectedNode.geometry?.materials.first?.copy() as! SCNMaterial
                                clonedMaterial.diffuse.contents = newColor.uColor
                                node.enumerateChildNodes { aa, _ in
                                    //print(aa.name)
                                    aa.geometry?.materials = [clonedMaterial]
                                }
                                return
                            }
                        }
                    } else {
                        if selectedStyle == "A" {
                            atomNodes.enumerateChildNodes { atom, _ in
                                guard atom.name!.contains("_") else {return}
                                let currentAtom = atom.name?.split(separator: "_")[1]
                                let currentMolecule = atom.name?.split(separator: "_")[3]
                                if currentAtom == selectedType && currentMolecule == moleculeName {
                                    atom.geometry?.materials.first?.diffuse.contents = newColor.uColor
                                }
                            }
                        }
                        if selectedStyle == "C" {
                            cartoonNodes.enumerateChildNodes { atom, _ in
                                guard atom.name!.contains("_") else {return}
                                let currentAtom = atom.name?.split(separator: "_")[1]
                                let currentMolecule = atom.name?.split(separator: "_")[3]
                                if currentAtom == selectedType && currentMolecule == moleculeName {
                                    atom.geometry?.materials.first?.diffuse.contents = newColor.uColor
                                }
                            }
                        }
                    }
                }
                
            }
        } else {
            for sel in selectedAtoms {
                guard sel.selectedNode.name!.contains("_") else {return}
                let clonedGeometry = (sel.selectedNode.geometry?.copy())! as! SCNGeometry
                let clonedMaterial = (clonedGeometry.materials.first?.copy())! as! SCNMaterial
                clonedMaterial.diffuse.contents = newColor.uColor
                clonedGeometry.materials = [clonedMaterial]
                sel.selectedNode.geometry = clonedGeometry
            }
        }
    }
    
    func generateSquareSelection(to: CGPoint) {
        
    }
    
}
