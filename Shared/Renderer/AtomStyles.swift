//
//  MolecularTools.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/8/22.
//

import ProteinKit

extension MoleculeRenderer {
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
    
    internal func scaleVdW(scale: Double) {
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
}
