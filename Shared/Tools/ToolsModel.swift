//
//  ToolsModel.swift
//  Atomic
//
//  Created by Christian Dominguez on 11/10/21.
//

import SwiftUI


enum mainTools: String, CaseIterable, Identifiable {
    case manipulate
    case edit
    case measure
    
    var id: String {self.rawValue}
}

enum editTools: CaseIterable {
    case addAtom
    case removeAtom
    case selectAtom
}

struct MyButtonStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundColor(.white)
      .background(configuration.isPressed ? Color.red : Color.blue)
      .cornerRadius(8.0)
  }

}
