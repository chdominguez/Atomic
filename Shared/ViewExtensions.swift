//
//  CustomViewModifiers.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/12/21.
//

import SwiftUI

/// View modifier for UI buttons
struct AtomicButton: ViewModifier {
    
    func body(content: Content) -> some View {
        #if os(macOS)
        content
        #else
            content
                .buttonStyle(.plain)
                .frame(height: 30)
                .frame(minWidth: 60)
                .padding(.horizontal)
                .background {
                    Color.buttonGradient
                }
                .cornerRadius(15)
        #endif
    }
}

// View modifier for custom buttons that are not part of SwiftUI class "Button". I.e. a Text with .onTapGesture
struct AtomicNoButton: ViewModifier {

    var widthButton: CGFloat = 80
    
    func body(content: Content) -> some View {
        content
            .frame(height: 30)
            .frame(minWidth: 60)
            .padding(.horizontal)
            .background {
                Color.buttonGradient
            }
            .cornerRadius(15)
    }
}


// Add view modifiers directly as a View extension
extension View {
    func atomicButton(fixed: Bool = false) -> some View {
        modifier(AtomicButton())
    }
    func atomicNoButton() -> some View {
        modifier(AtomicNoButton())
    }
}

// New window for both platforms

extension View {
    func openNewWindow(with title: String = "New Window", multiple: Bool = true, controller: MoleculeViewModel? = nil) {
        #if os(macOS)
        windowInternalMacOS(title, multiple, controller)
        #elseif os(iOS)
        WindowInternaliOS(controller: controller)
        #endif
    }
}
