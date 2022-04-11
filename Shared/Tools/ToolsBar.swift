//
//  ToolsBar.swift
//  Atomic
//
//  Created by Christian Dominguez on 17/3/22.
//

import SwiftUI

struct ToolsBar: View {
    
    @ObservedObject var windowManager = WindowManager.shared
    @ObservedObject var toolsController = ToolsController.shared
    @ObservedObject var currentController: RendererController
    @ObservedObject var ptableController = PeriodicTableViewController.shared
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "atom")
                Text(ptableController.selectedAtom.rawValue)
            }.atomicNoButton()
                .foregroundColor(toolsController.selected2Tool == .addAtom ? .red : .primary)
                .onTapGesture {
                    ToolsController.shared.selected2Tool = .addAtom
                    guard let controller = windowManager.currentController else {return}
                    #warning("TODO: Better implementation of new windows for both ios and macos")
                    #if os(macOS)
                    PTable().openNewWindow(with: "Periodic Table", and: .ptable, controller: controller)
                    #elseif os(iOS)
                    PTable().openNewWindow(controller: controller)
                    #endif
                }
            HStack {
                Image(systemName: "hand.tap")
                Text("Select")
            }.atomicNoButton()
                .foregroundColor(toolsController.selected2Tool == .selectAtom ? .red : .primary)
                .onTapGesture {
                    ToolsController.shared.selected2Tool = .selectAtom
                }
            HStack {
                Image(systemName: "link")
                Text("Bond")
            }.atomicNoButton()
                .onTapGesture {
                    windowManager.currentController?.renderer?.bondSelectedAtoms()
                }
            HStack {
                Image(systemName: "trash")
                Text("Erase")
            }
            .atomicNoButton()
            .foregroundColor(toolsController.selected2Tool == .removeAtom ? .red : Color.primary)
            .onTapGesture {
                ToolsController.shared.selected2Tool = .removeAtom
            }
            if !(windowManager.currentController?.renderer?.selectedAtoms.isEmpty ?? true){
                HStack {
                    Image(systemName: "trash.slash.circle")
                    Text("Erase selected")
                }
                .atomicNoButton()
                .onTapGesture {
                    windowManager.currentController?.renderer?.eraseSelectedAtoms()
                }
            }
        }
        .frame(maxHeight: 50)
    }
}
