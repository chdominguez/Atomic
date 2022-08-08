//
//  Debug.swift
//  Atomic_macos
//
//  Created by Christian Dominguez on 4/8/22.
//

import ProteinKit
import SwiftUI

class DebugWindow: ObservableObject {
    @Published var totalNodes = 0
    @Published var cameraPosition = SCNVector3.zero
    @Published var nodes: [SCNNode] = []
    
    let renderer: MoleculeRenderer
    
    init(renderer: MoleculeRenderer) {
        self.renderer = renderer
    }
    
    func fetchNodes() {
        nodes = []
        renderer.scene!.rootNode.enumerateHierarchy { node, _ in
            nodes.append(node)
        }
        totalNodes = nodes.count
    }
    
}

struct DebugWindowView: View {
    
    @ObservedObject var debugger: DebugWindow
    
    init(renderer: MoleculeRenderer) {
        self.debugger = DebugWindow(renderer: renderer)
    }
    
    var body: some View {
        VStack {
            List {
                Text("# Nodes \(debugger.totalNodes)")
                ForEach(debugger.nodes, id: \.self) { node in
                    HStack {
                        Text(node.name ?? "Unnamed")
                        Text("x: \(node.position.dx), y: \(node.position.dy), z: \(node.position.dz)")
                        Text("Pivot: \(node.pivot.m11), \(node.pivot.m22), \(node.pivot.m33), \(node.pivot.m44)")
                    }
                }
            }
            Button("Fetch info") {
                debugger.fetchNodes()
            }
        }.frame(width: 800, height: 600, alignment: .center)
    }
}
