//
//  ColorSettings.swift
//  Atomic
//
//  Created by Christian Dominguez on 11/4/22.
//
import SceneKit
import SwiftUI


class GlobalSettings: ObservableObject {
    
    static let shared = GlobalSettings()
    
    @Published var colorSettings = ColorSettings()
    
    @Published var atomStyle: AtomStyle = .ballAndStick
    
}


/// Colors of atoms, bonds, and other properties of the SceneKit scene. This class is meant to reside in GlobalSettings as a property.
class ColorSettings: ObservableObject {
    
    /// Background color of the SceneKit view
    @Published var backgroundColor: Color = .white
    
    /// Core material. For changing roughness, shinnies...
    var coreMaterial: SCNMaterial!
    
    //MARK: Bonds
    /// The color of the bond. Default: .gray
    @Published var bondColor: Color = .gray
    
    /// The material of the bond, defaulted to coreMaterial
    var bondMaterial: SCNMaterial!
    
    //MARK: Atoms
    /// Color of each atom. Array position represents the atomic number. For position 0, the default white value is set.
    @Published var atomColors: [Color]!
    /// Materials for each atom. Default of coreMaterial + color of each atom
    var atomMaterials: [Element : SCNMaterial]!
    
    var selectionColor: Color = .cyan
    var selectionMaterial: SCNMaterial!
    
    //Backbone                  |
    //                          |
    //Cartoon helix             | TODO: implement
    //                          |
    //Cartoon beta sheets       |
    
    init() {
        self.coreMaterial = setupCoreMaterial()
        self.bondMaterial = setupBondMaterial()
        (self.atomColors, self.atomMaterials) = setupAtomMaterials()
        self.selectionMaterial = setupSelectionMaterial()
    }
    
    /// Sets the core material to the default values and inits the property
    private func setupCoreMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UColor.gray // Default coreMaterial color is equal to the bond color
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.4
        material.roughness.contents = 0.5
        
        return material
    }
    
    /// Sets the atom materials  and colors to the default values and inits the property
    private func setupAtomMaterials() -> ([Color], [Element : SCNMaterial]) {
        
        var atomColors: [Color] = []
        var atomMaterials: [Element : SCNMaterial] = [:]
        
        //First color "0 index" white, the rest of the indexes correpsond with the atomic number
        atomColors.append(.white)
        
        for atom in Element.allCases {
            atomColors.append(atom.color)
            let aMaterial = coreMaterial!.copy() as! SCNMaterial
            aMaterial.diffuse.contents = atom.color.uColor
            atomMaterials[atom] = aMaterial
        }
        return (atomColors, atomMaterials)
    }
    
    /// Sets the bond material equal to the coreMaterial
    private func setupBondMaterial() -> SCNMaterial {
        let bondMaterial = coreMaterial!.copy() as! SCNMaterial
        bondMaterial.diffuse.contents = bondColor.uColor
        
        return bondMaterial
    }
    
    private func setupSelectionMaterial() -> SCNMaterial {
        let selectionMaterial = SCNMaterial()
        selectionMaterial.diffuse.contents = selectionColor.uColor
        return selectionMaterial
    }
    
    /// SwiftUI color picker changes a Color type. After the color is set, the material corresponding to the atom has to be updated with the new color
    /// - Parameter element: Element of which the color changed
    func updateNodeAtomMaterial(_ element: Element) {
        atomMaterials[element]!.diffuse.contents = atomColors[element.atomicNumber].uColor // Force unwrap as the element should exist
    }
    /// SwiftUI color picker changes a Color type. After the color is set, the material corresponding to the bond has to be updated with the new color
    func updateBondNodeMaterial() {
        bondMaterial.diffuse.contents = bondColor.uColor
    }
    
    func updateSelectionMaterial() {
        selectionMaterial.diffuse.contents = selectionColor.uColor
    }
    
}

#warning("TODO: 3D structures for folded proteins: Helix, Beta-sheet, turns...")

/// Geometries for SceneKit nodes. These geometries implement the materials defined in the ColorSettings class
class NodeGeometries {
    
    let settings = GlobalSettings.shared
    
    /// A SCNSphere (type of geometry) is assigned to each atom with its corresponding SCNMateria from ColorSettingsl.bondMaterial
    var atoms: [Element : SCNSphere]!
    
    /// A SCNCylinder (type of geometry) is assigned to the bond with its corresponding SCNMaterial from ColorSettings.atomColors
    var bond: SCNCylinder!
    
    init() {
        atoms = setupAtomGeometries()
        bond = setupBondGeometries()
    }
    
    /// Inits the atoms property with default values for the geometries
    private func setupAtomGeometries() -> [Element : SCNSphere] {
        
        let materials = GlobalSettings.shared.colorSettings.atomMaterials!
        
        var atoms: [Element : SCNSphere] = [:]
        
        for element in Element.allCases {
            let sphere = SCNSphere()
            sphere.radius = element.radius
            sphere.materials = [materials[element]!]
            atoms[element] = sphere
        }
        
        return atoms
    }
    
    private func setupBondGeometries() -> SCNCylinder {
        let material = GlobalSettings.shared.colorSettings.bondMaterial!
        let cylinder = SCNCylinder()
        cylinder.radius = 0.1
        cylinder.materials = [material]
        
        return cylinder
    }
    
    
    private func setupCartoonGeometries() {
        
    }
}
