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
    var body: some View {
        VStack {
            Toggle(isOn: $changeSameType) {
                Text("Change all of same type")
            }
            Toggle(isOn: $affectMolecules) {
                Text("Change for all molecules")
            }.disabled(!changeSameType)
            ColorPicker("Selection color", selection: $color).onChange(of: color) { newValue in
                controller.renderer?.newColorForSelection(newColor: newValue, changeOfSameType: changeSameType, affectMolecules: affectMolecules)
            }
        }.frame(width: 200, height: 200, alignment: .center)
    }
}
