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
                .foregroundColor(toolsController.selectedTool == .addAtom ? .red : .primary)
                .onTapGesture {
                    ToolsController.shared.selectedTool = .addAtom
                    guard let controller = windowManager.currentController else {return}
                    #warning("TODO: Better implementation of new windows for both ios and macos")
                    PTable().openNewWindow(with: "Periodic Table", multiple: false, controller: controller)
                }
            HStack {
                Image(systemName: "hand.tap")
                Text("Select")
            }.atomicNoButton()
                .foregroundColor(toolsController.selectedTool == .selectAtom ? .red : .primary)
                .onTapGesture {
                    ToolsController.shared.selectedTool = .selectAtom
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
            .foregroundColor(toolsController.selectedTool == .removeAtom ? .red : Color.primary)
            .onTapGesture {
                ToolsController.shared.selectedTool = .removeAtom
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
