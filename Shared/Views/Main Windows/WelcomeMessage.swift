//
//  WelcomeMessage.swift
//  Atomic
//
//  Created by Christian Dominguez on 12/12/21.
//

import SwiftUI

struct WelcomeMessage: View {
    var body: some View {
        VStack {
            Image("icon").resizable().frame(width: 150, height: 150, alignment: .center)
            Text("Welcome to Atomic!").font(.title)
        }
    }
}


