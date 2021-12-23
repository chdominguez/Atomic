//
//  Molecule3DView.swift
//  Atomic
//
//  Created by Christian Dominguez on 23/12/21.
//

import SwiftUI

struct Molecule3DView: View {
    
    @ObservedObject var controller: RendererController
    
    var body: some View {
        if controller.didLoadAtLeastOne {
            VStack {
                ZStack {
                    SceneUI(controller: controller)
                    VStack {
                        Spacer()
                        if !controller.didLoadAllScenes {
                            progressview.foregroundColor(.black)
                        }
                    }
                }
                toolbar2
            }
        }
        else {
            VStack {
                Spacer()
                progressview.onAppear {
                        controller.loadAllScenes()
                    }
            }
        }
        
    }
}

extension Molecule3DView {
    
    private var progressview: some View {
        VStack {
            Image(systemName: "atom")
            Text("Loading: \(controller.stepsPreloaded)/\(controller.steps.count)")
            ProgressView(value: controller.progress)
        }.padding()
    }
    
    private var toolbar2: some View {
        HStack {
            Text("\(controller.selectedIndex + 1) / \(controller.steps.count)")
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
            Text("Energy: \(controller.showingStep.energy)")
            Spacer()
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
