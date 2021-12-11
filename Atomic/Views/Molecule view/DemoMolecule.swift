//
//  DemoMolecule.swift
//  DemoMolecule
//
//  Created by Christian Dominguez on 19/9/21.
//

import SwiftUI

struct DemoMolecule: View {
    
    @ObservedObject var controller = RendererController()
    
    @StateObject var demoVM = MoleculeViewModel()
    
    @EnvironmentObject var ptablecontroller: PeriodicTableViewController
    
    @State var molecule: Molecule = MolReader.demoMoleculeObject
    @Binding var createNewBonds: Bool
    
    private var scene: SceneUI {
        SceneUI(controller: controller)
    }
    
    var body: some View {
        scene
    }
}


