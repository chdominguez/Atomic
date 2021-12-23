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
            progressview.onAppear {
                    controller.loadAllScenes()
                }
        }
        
    }
}

extension Molecule3DView {
    
    private var progressview: some View {
        VStack {
            Image(systemName: "atom")
            Text("Loading molecule")
            ProgressView(value: controller.progress)
        }.padding()
    }
    
    private var toolbar2: some View {
        HStack {
            Text("\(controller.selectedIndex + 1) / \(controller.steps.count)")
            Button {
                controller.previousScene()
            } label: {
                Image(systemName: "chevron.left")
            }
            Button {
                controller.nextScene()
            } label: {
                Image(systemName: "chevron.right")
            }
            Spacer()
            Text("Energy: \(controller.showingStep.energy)")
            Spacer()
            Text("Play")
            Button {
                controller.playAnimation()
            } label: {
                Image(systemName: controller.isPlaying ? "stop.fill" : "play.fill").foregroundColor(controller.isPlaying ? .red : .green)
            }
        }
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
}
