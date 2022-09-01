//
//  Appearance.swift
//  Atomic
//
//  Created by Christian Dominguez on 31/8/22.
//

import SwiftUI

struct AppearanceView: View {
    @ObservedObject var controller: AtomicMainController
    @State var color: Color = .white
    @State var changeSameType = false
    @State var affectMolecules = false
    @State var types: SelectionTypes = .atom
    var body: some View {
        VStack {
            Toggle(isOn: $changeSameType) {
                Text("Change all of same type")
            }
            Picker("Types", selection: $types) {
                Text(controller.renderer!.cartoonNodes.isHidden ? "Atoms" : "Aminoacids").tag(SelectionTypes.atom)
                Text("Structure").tag(SelectionTypes.structure).disabled(!controller.renderer!.showingStep.isProtein)
            }.disabled(!changeSameType)
            Toggle(isOn: $affectMolecules) {
                Text("Change for all molecules")
            }.disabled(!changeSameType)
            ColorPicker("Selection color", selection: $color).onChange(of: color) { newValue in
                controller.renderer?.newColorForSelection(newColor: newValue, changeOfSameType: changeSameType, affectMolecules: affectMolecules, types: types)
            }
        }.frame(width: 200, height: 200, alignment: .center)
    }
    
    public enum SelectionTypes: String {
        case atom = "Atoms, aminoacids"
        case structure = "Structure"
    }
    
}
