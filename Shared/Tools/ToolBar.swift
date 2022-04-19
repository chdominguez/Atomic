//
//  ToolsBar.swift
//  Atomic
//
//  Created by Christian Dominguez on 17/3/22.
//

import SwiftUI

struct AtomicToolsView: View {
    
    @ObservedObject var controller: MoleculeRenderer
    @ObservedObject var ptableController = PeriodicTableViewController.shared
    
    var body: some View {
        ZStack {
            //MARK: Main toolbar
            HStack {
                HStack {
                    Image(systemName: "atom")
                    Text(ptableController.selectedAtom.rawValue)
                }.atomicNoButton()
                    .foregroundColor(controller.selectedTool == .addAtom ? .red : .primary)
                    .onTapGesture {
                        controller.selectedTool = .addAtom
                        #if os(macOS)
                        PTable().openNewWindow(type: .ptable)
                        #elseif os(iOS)
                        PTable().openNewWindow()
                        #endif
                    }
                HStack {
                    Image(systemName: "hand.tap")
                    Text("Select")
                }.atomicNoButton()
                    .foregroundColor(controller.selectedTool == .selectAtom ? .red : .primary)
                    .onTapGesture {
                        controller.selectedTool = .selectAtom
                    }
                HStack {
                    Image(systemName: "link")
                    Text("Bond")
                }.atomicNoButton()
                    .onTapGesture {
                        controller.bondSelectedAtoms()
                    }
                HStack {
                    Image(systemName: "trash")
                    Text(controller.selectedAtoms.isEmpty ? "Erase" : "Erase selected")
                }
                .atomicNoButton()
                .foregroundColor(controller.selectedTool == .removeAtom ? .red : Color.primary)
                .onTapGesture {
                    controller.selectedAtoms.isEmpty ? controller.selectedTool = .removeAtom : controller.eraseSelectedAtoms()
                }
            }.frame(maxHeight: 50)
                .animation(.easeIn, value: controller.selectedAtoms.isEmpty)
            
            //MARK: Distance/angle
            if controller.showDistangle {
                HStack {
                    ZStack {
                        Slider(value: controller.bindingDoubleDistangle, in: 0.5...5)
                            .offset(x: 0, y: -30)
                        TextField("Value", text: $controller.measuredDistangle, onCommit: {
                            controller.editDistanceOrAngle()
                        })
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .atomicNoButton()
                    }
                    .frame(maxWidth: 80)
                    .padding(.horizontal)
                    Spacer()
                }
            }
        }
    }
}
