//
//  CustomViewModifiers.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/12/21.
//

import SwiftUI

struct NeumorphicButton<S: Shape>: ButtonStyle {
    
    let shape: S
    let gradient1 = Color.neumorStart
    let gradient2 = Color.neumorEnd
    let vpadding: CGFloat
    let hpadding: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, vpadding)
            .padding(.horizontal, hpadding)
            .contentShape(shape)
            .background(
                ZStack {
                    if configuration.isPressed {
                        shape
                        .fill(gradient1)
                    } else {
                        shape
                        .fill(gradient2)
                        .shadow(color: .neumorShadow.opacity(0.3), radius: 10, x: 0, y: 10)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut, value: configuration.isPressed)
    }
}

// For aplying to .onTapGesture views
struct NonButtonNeumorphic: ViewModifier {
    
    @Binding var isPressed: Bool
    let gradient1 = Color.blueGradient1
    let gradient2 = Color.blueGradient2

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if isPressed {
                        content
                        .background(gradient1)
                    } else {
                        content
                        .background(gradient2)
                        .shadow(color: .neumorShadow.opacity(0.3), radius: 10, x: 0, y: 10)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.9 : 1)
            .animation(.easeOut, value: isPressed)
        
    }
        
}


// Custom view modifiers
extension View {
    
    /// Custom modifier for buttons
    func toolbarButton() -> some View {
        buttonStyle(NeumorphicButton(shape: RoundedRectangle(cornerRadius: 25), vpadding: 6, hpadding: 20))
    }
    
    /// Neumorphic UI
    func neumorphicButton<S: Shape>(_ shape: S) -> some View {
        buttonStyle(NeumorphicButton(shape: shape, vpadding: 30, hpadding: 30))
    }
    
    /// Intended for views that are not Buttons but can act as so
    func neumorphicPlain(isPressed: Binding<Bool>) -> some View {
        modifier(NonButtonNeumorphic(isPressed: isPressed))
    }
    
    /// .onDrop of modifier adapted for both platforms
    func onDropOfAtomic(delegate: DropDelegate) -> some View {
        #if os(macOS)
        self.onDrop(of: [.fileURL], delegate: delegate)
        #elseif os(iOS)
        self.onDrop(of: AtomicFileOpener.shared.types, delegate: delegate)
        #endif
    }
}
