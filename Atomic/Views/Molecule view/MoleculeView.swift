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
            if moleculeVM.loading {
                ProgressView()
            }
            
            VStack(spacing: 20) {

                
                if !moleculeVM.steps.isEmpty {
                    
                    HStack {
                        EnergyChart(steps: moleculeVM.steps).frame(width: 300, height: 300)
                        VStack {
                            VStack {
                                HStack {
                                    Button {
                                        moleculeVM.indexButton(.back)
                                    } label: {
                                        Image(systemName: "chevron.left.circle")
                                    }
                                    Text("\(moleculeVM.stepIndex + 1) / \(moleculeVM.steps.count)")
                                    Button {
                                        moleculeVM.indexButton(.next)
                                    } label: {
                                        Image(systemName: "chevron.right.circle")
                                    }
                                    Text("Energy: \(moleculeVM.steps[moleculeVM.stepIndex].energy)")
                                }
                                Slider(value: $moleculeVM.stepSlider, in: 0...Double(moleculeVM.steps.count), step: 1.0) { editing in
                                    if !editing {
                                        moleculeVM.stepIndex = Int(moleculeVM.stepSlider)
                                    }
                                }
                            }
                            
                            SceneUI(controller: moleculeVM.controller)
                        }
                        if !moleculeVM.steps[moleculeVM.stepIndex].frequencys.isEmpty {
                            ScrollView {
                                ForEach(moleculeVM.steps[moleculeVM.stepIndex].frequencys, id: \.self) { data in
                                    Text("\(data)")
                                }
                            }
                            .padding()
                            .frame(width: 200, height: 300)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                        }
                    }
                }
            }.padding()
                .opacity(moleculeVM.loading ? 0.5 : 1)
        }
        
    }
}

