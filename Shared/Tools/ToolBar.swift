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
                atomButton
                selectButton
                bondSelected
                erase
                sidebar
            }
            .frame(maxHeight: 50)            
            //MARK: Distance/angle
            if controller.showDistangle {
                distanceEditor
            }
        }
    }
}


extension AtomicToolsView {
    private var atomButton: some View {
        Button {
            controller.selectedTool = .addAtom
            #if os(macOS)
            PTable().openNewWindow(type: .ptable)
            #elseif os(iOS)
            PTable().openNewWindow()
            #endif
        } label: {
            HStack {
                Image(systemName: "atom")
                Text(ptableController.selectedAtom.rawValue)
            }.foregroundColor(controller.selectedTool == .addAtom ? .accentColor : .primary)
        }
        .toolbarButton()
    }
    private var selectButton: some View {
        Button {
            controller.selectedTool = .selectAtom
        } label: {
            HStack {
                Image(systemName: "hand.tap")
                Text("Select")
            }.foregroundColor(controller.selectedTool == .selectAtom ? .accentColor : .primary)
        }
        .toolbarButton()
    }
    
    private var bondSelected: some View {
        Button {
            controller.bondSelectedAtoms()
        } label: {
            HStack {
                Image(systemName: controller.currentBondType.symbol)
                Text("Bond")
            }.foregroundColor((controller.selectedAtoms.count != 2 || !controller.cartoonNodes.isHidden) ? .gray : .primary)
        }
        .toolbarButton()
        .contextMenu(menuItems: {
            Button {controller.currentBondType = .single} label: {
                Image(systemName: "line.diagonal")
                Text("Single")
            }
            Button {controller.currentBondType = .double} label: {
                Image(systemName: "equal")
                Text("Dobule")
            }
            Button {controller.currentBondType = .triple} label: {
                Image(systemName: "line.3.horizontal")
                Text("Triple")
            }
        })
        .disabled(controller.selectedAtoms.count != 2 || !controller.cartoonNodes.isHidden)
    }
    
    private var erase: some View {
        Button {
            controller.selectedAtoms.isEmpty ? controller.selectedTool = .removeAtom : controller.eraseSelectedAtoms()
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Erase")
            }.foregroundColor(controller.selectedTool == .removeAtom ? .accentColor : .primary)
        }
        .toolbarButton()
    }
    
    private var sidebar: some View {
        Button {
            controller.showSidebar.toggle()
        } label: {
            HStack {
                Image(systemName: "sidebar.squares.right")
                Text("Molecules")
            }.foregroundColor(controller.showSidebar ? .accentColor : .primary)
        }
        .toolbarButton()
    }
    
    private var distanceEditor: some View {
        HStack {
            ZStack {
                Slider(value: controller.bindingDoubleDistangle, in: controller.maxRange)
                    .offset(x: 0, y: -30)
                TextField("Value", text: $controller.measuredDistangle, onCommit: {
                    controller.editDistanceOrAngle()
                })
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    //.toolbarButton()
            }
            .frame(maxWidth: 80)
            .padding(.horizontal)
            Spacer()
        }
    }
}
