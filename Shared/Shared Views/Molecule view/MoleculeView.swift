//
//  FileImporter.swift
//  FileImporter
//
//  Created by Christian Dominguez on 16/8/21.
//

import SwiftUI
import SceneKit

struct MoleculeView: View {
    
    @ObservedObject var moleculeVM: MoleculeViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {

                SceneUI(controller: moleculeVM.controller)
                
            }.padding()
                .opacity(moleculeVM.loading ? 0.5 : 1)
        }
        
    }
}

