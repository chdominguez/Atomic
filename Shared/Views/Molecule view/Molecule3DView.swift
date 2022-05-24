//
//  Molecule3DView.swift
//  Atomic
//
//  Created by Christian Dominguez on 23/12/21.
//

import SwiftUI
import Combine

/// View that hosts the SceneKit representable and shows the tools + the molecule
struct Molecule3DView: View {
    
    @ObservedObject var controller: MoleculeRenderer
    
    var body: some View {
        if controller.didLoadAtoms {
            VStack(spacing: 0) {
                ZStack {
                    SceneUI(controller: controller).ignoresSafeArea()
                    VStack {
                        if !controller.didLoadAtoms {
                            progressview.foregroundColor(.primary)
                        }
                        Spacer()
                        AtomicToolsView(controller: controller).padding(.vertical, 5)
                    }
                }
                stepsToolbar
                #if os(macOS)
                .padding(.top, 5)
                #endif
            }
        }
        else {
            progressview.onAppear {
                controller.loadScenes()
            }
        }
        
    }
}

extension Molecule3DView {
    
    private var progressview: some View {
        VStack {
            ProgressView()
            Text("Rendering atoms...")
        }
    }
    
    private var stepsToolbar: some View {
        HStack {
            HStack {
                TextField("Step", text: Binding(get: {
                    String(controller.stepToShow)
                }, set: {controller.stepToShow = filterStoI($0, maxValue: controller.steps.count)}))
                    .frame(maxWidth: 50)
                Text("of \(controller.steps.count)")
            }
            Button {
                controller.previousScene()
            } label: {
                Image(systemName: "chevron.left")
            }.stepBarButton()
            Button {
                controller.nextScene()
            } label: {
                Image(systemName: "chevron.right")
            }
            .stepBarButton()
            Spacer()
            if controller.showingStep.isFinalStep {
                if let energy = controller.showingStep.energy {
                    Text("Final energy for job \(controller.showingStep.jobNumber) : \(energy)")
                }
                else {
                    Text("Final geometry")
                }
            }
            else if let energy = controller.showingStep.energy {
                if #available(macOS 12.0, *) {
                    Text("Energy: \(energy)").textSelection(.enabled)
                } else {
                    // Fallback on earlier versions
                    Text("Energy: \(energy)")
                }
            }
             else {
                Text("Input geometry for job \(controller.showingStep.jobNumber)")
            }
            Spacer()
            Text("FPS:")
            TextField("FPS", text: Binding(get: {
                String(controller.playBack)
            }, set: {controller.playBack = filterStoI($0, maxValue: 60)}))
                .frame(maxWidth: 50)
            Text("Play")
            Button {
                controller.playAnimation()
            } label: {
                Image(systemName: controller.isPlaying ? "stop.fill" : "play.fill")
                    .frame(width: 10, height: 10)
                    .foregroundColor(controller.isPlaying ? .red : .green)
            }.stepBarButton()
        }
        .padding(.horizontal)
#if os(macOS)
        .padding(.bottom, 5)
#else
        .padding(.vertical, 5)
        .background(Color.gray)
#endif
        
    }
}
