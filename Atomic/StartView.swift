//
//  StartView.swift
//  StartView
//
//  Created by Christian Dominguez on 26/8/21.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            Spacer()
        }.background(Color.red)
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
