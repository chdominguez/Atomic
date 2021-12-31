//
//  InputfileView.swift
//  Atomic
//
//  Created by Christian Dominguez on 31/12/21.
//

import SwiftUI

struct InputfileView: View {
    
    @State var fileInput: String
    
    var body: some View {
        TextEditor(text: $fileInput).font(.system(size: 16))
    }
}

