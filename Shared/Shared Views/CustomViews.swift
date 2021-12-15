//
//  CustomViewModifiers.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/12/21.
//

import SwiftUI

struct AtomicButton: ViewModifier {

    var widthButton: CGFloat = 80
    
    let gradientColor = LinearGradient(colors: [Color("ButtonColor1"), Color("ButtonColor2")], startPoint: .topTrailing, endPoint: .bottomLeading)
    
    func body(content: Content) -> some View {
            
        content
            .frame(height: 30)
            .frame(minWidth: 60)
            .buttonStyle(.plain)
            .padding(.horizontal)
            .background {
                gradientColor
            }
            .cornerRadius(15)
        
            
    }
}


extension View {
    func atomicButton() -> some View {
        modifier(AtomicButton())
    }
}

struct BlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.blue : Color.white)
            .background(configuration.isPressed ? Color.white : Color.blue)
            .cornerRadius(6.0)
            .padding()
    }
}

