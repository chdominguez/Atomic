//
//  CustomViewModifiers.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/12/21.
//

import SwiftUI

struct AtomicButton: ViewModifier {

    var widthButton: CGFloat = 80
    
    func body(content: Content) -> some View {
        
        #if os(macOS)
        content
        #else
        content
            .frame(height: 30)
            .frame(minWidth: 60)
            .buttonStyle(.plain)
            .padding(.horizontal)
            .background {
                CustomColors.gradientColor
            }
            .cornerRadius(15)
        #endif
    }
}


extension View {
    func atomicButton() -> some View {
        modifier(AtomicButton())
    }
}

