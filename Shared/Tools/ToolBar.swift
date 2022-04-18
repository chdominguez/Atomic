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
            if controller.measuredDistance != nil {
                HStack {
                    TextField("", text: Binding(get: {
                        guard let distance = controller.measuredDistance else {return ""}
                        return String(distance)
                    }, set: { newValue in
                        controller.measuredDistance = controller.editDistanceOrAngle(newValue)
                    }))
                        .textFieldStyle(.plain)
                        .atomicNoButton()
                        .padding(.horizontal)
                    Spacer()
                }
            }
        }
    }
}
