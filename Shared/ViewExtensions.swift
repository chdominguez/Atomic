//
//  CustomViewModifiers.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/12/21.
//

import SwiftUI
import Neumorphic

struct NeumorphicButton<S: Shape>: ButtonStyle {
    
    let shape: S
    let gradient1 = Color.Neumorphic.main
    let gradient2 = Color.Neumorphic.secondary
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
    let gradient1 = Color.Neumorphic.main
    let gradient2 = Color.Neumorphic.secondary

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

public enum SoftButtonPressedEffect {
    case none
    case flat
    case hard
}

extension Button {
    
    /// Custom modifier for buttons
    func toolbarButton() -> some View {
        neumorphicAtomicButton(RoundedRectangle(cornerRadius: 25), padding: 10, darkShadowColor: Color.clear, lightShadowColor: Color.clear)
    }
    
    func stepBarButton() -> some View {
        neumorphicAtomicButton(Circle(), padding: 10)
    }
    

    public func neumorphicAtomicButton<S : Shape>(_ content: S, padding : CGFloat = 16, mainColor : Color = Color.Neumorphic.main, textColor : Color = Color.Neumorphic.secondary, darkShadowColor: Color = Color.Neumorphic.darkShadow, lightShadowColor: Color = Color.Neumorphic.lightShadow, pressedEffect : SoftButtonPressedEffect = .hard) -> some View {
        self.buttonStyle(ASoftDynamicButtonStyle(content, mainColor: mainColor, textColor: textColor, darkShadowColor: darkShadowColor, lightShadowColor: lightShadowColor, pressedEffect : pressedEffect, padding:padding))
    }

    
}

public struct ASoftDynamicButtonStyle<S: Shape> : ButtonStyle {

    var shape: S
    var mainColor : Color
    var textColor : Color
    var darkShadowColor : Color
    var lightShadowColor : Color
    var pressedEffect : SoftButtonPressedEffect
    var padding : CGFloat
    
    public init(_ shape: S, mainColor : Color, textColor : Color, darkShadowColor: Color, lightShadowColor: Color, pressedEffect : SoftButtonPressedEffect, padding : CGFloat = 16) {
        self.shape = shape
        self.mainColor = mainColor
        self.textColor = textColor
        self.darkShadowColor = darkShadowColor
        self.lightShadowColor = lightShadowColor
        self.pressedEffect = pressedEffect
        self.padding = padding
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(textColor)
                .padding(padding)
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .background(
                    ZStack{
                        if pressedEffect == .flat {
                            shape.stroke(darkShadowColor, lineWidth : configuration.isPressed ? 1 : 0)
                            .opacity(configuration.isPressed ? 1 : 0)
                            shape.fill(mainColor)
                        }
                        else if pressedEffect == .hard {
                            shape.fill(mainColor)
                                .softInnerShadow(shape, darkShadow: darkShadowColor, lightShadow: lightShadowColor, spread: 0.15, radius: 3)
                                .opacity(configuration.isPressed ? 1 : 0)
                        }
                        
                        shape.fill(mainColor)
                            .softOuterShadow(darkShadow: darkShadowColor, lightShadow: lightShadowColor, offset: 6, radius: 3)
                            .opacity(pressedEffect == .none ? 1 : (configuration.isPressed ? 0 : 1) )
                    }
                )
                .animation(.easeInOut, value: configuration.isPressed)
    }
    
}

