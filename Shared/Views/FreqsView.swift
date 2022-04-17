//
//  FreqsView.swift
//  Atomic
//
//  Created by Christian Dominguez on 31/12/21.
//

import SwiftUI

struct FreqsView: View {
    
    let freqs: [Double]
    
    var body: some View {
        VStack {
            HStack {
                Text("Mode")
                Text("Frequency")
            }.font(.title)
            ScrollView {
                ForEach(freqs.indices, id: \.self) { index in
                    HStack {
                        Text("\(index)")
                        Text("\(freqs[index])")
                    }
                    .font(.system(size: 16))
                        .padding(.vertical, 3)
                }
            }
        }.padding()

    }
}

struct FreqsView_Previews: PreviewProvider {
    static var previews: some View {
        FreqsView(freqs: [20, 30])
    }
}
