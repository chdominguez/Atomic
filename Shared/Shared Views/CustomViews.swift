//
//  CustomViewModifiers.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/12/21.
//

import SwiftUI

struct AtomicButton: ViewModifier {
    
    let fixed: Bool
    
    func body(content: Content) -> some View {
        #if os(macOS)
        content
        #else
        if fixed {
            content
                .buttonStyle(.plain)
                .frame(height: 30)
                .frame(width: 80)
                .padding(.horizontal)
                .background {
                    CustomColors.gradientColor
                }
                .cornerRadius(15)
        } else {
            content
                .buttonStyle(.plain)
                .frame(height: 30)
                .frame(minWidth: 60)
                .padding(.horizontal)
                .background {
                    CustomColors.gradientColor
                }
                .cornerRadius(15)
        }
        #endif
    }
}

struct AtomicNoButton: ViewModifier {

    var widthButton: CGFloat = 80
    
    func body(content: Content) -> some View {
        content
            .frame(height: 30)
            .frame(minWidth: 60)
            .padding(.horizontal)
            .background {
                CustomColors.gradientColor
            }
            .cornerRadius(15)
    }
}


extension View {
    func atomicButton(fixed: Bool = false) -> some View {
        if fixed {
            return modifier(AtomicButton(fixed: true))
        } else {
            return modifier(AtomicButton(fixed: false))
        }
    }
    func atomicNoButton() -> some View {
        modifier(AtomicNoButton())
    }
}

