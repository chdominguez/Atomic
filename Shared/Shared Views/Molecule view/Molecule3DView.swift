//
//  Molecule3DView.swift
//  Atomic
//
//  Created by Christian Dominguez on 23/12/21.
//

import SwiftUI
import Combine

struct Molecule3DView: View {
    
    @ObservedObject var controller: RendererController
    
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
                        ToolsBar(currentController: controller)
                    }
                }
                toolbar2
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
    
    private var toolbar2: some View {
        HStack {
            HStack {
                Text("\(controller.stringStep)")
//                TextField("Step", text: $controller.stringStep)
//                    .frame(maxWidth: 100)
//                    .onReceive(Just(controller.stringStep)) { newValue in
//                        controller.filterValue(newValue)
//                    }
                Text("\(controller.steps.count)")
            }
            //Text("\(controller.selectedIndex + 1) / \(controller.steps.count)")
            Button {
                controller.previousScene()
            } label: {
                Image(systemName: "chevron.left").atomicButton()
            }
            Button {
                controller.nextScene()
            } label: {
                Image(systemName: "chevron.right").atomicButton()
            }
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
                   Text("Energy: \(energy)")
            }
             else {
                Text("Input geometry for job \(controller.showingStep.jobNumber)")
            }
            Spacer()
            Text("FPS:")
            TextField("FPS", text: $controller.playBack)
                .frame(maxWidth: 50)
                .onReceive(Just(controller.playBack)) { newValue in
                    controller.filterPlayBackValue(newValue)
                }
            Text("Play")
            Button {
                controller.playAnimation()
            } label: {
                Image(systemName: controller.isPlaying ? "stop.fill" : "play.fill").foregroundColor(controller.isPlaying ? .red : .green).atomicButton()
            }
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
