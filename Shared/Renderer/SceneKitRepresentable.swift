
// Custom view representables. Usually, the AppKit/UIKit counterparts of SwiftUI views are faster and more customizable.

import SwiftUI
import SceneKit

// Cross-platform APIs compatibilities
#if os(iOS)
typealias Representable = UIViewRepresentable
typealias TapGesture = UITapGestureRecognizer
typealias PanGesture = UIPanGestureRecognizer
#elseif os(macOS)
typealias Representable = NSViewRepresentable
typealias TapGesture = NSClickGestureRecognizer
typealias PanGesture = NSPanGestureRecognizer
#endif

struct SceneUI: Representable {
    
    @ObservedObject var controller: MoleculeRenderer
    @ObservedObject var settings = GlobalSettings.shared
    @Environment(\.colorScheme) var colorScheme
        
    // View representables functions are different for each platform. Even tough the codes are exactly the same. Why Apple?
    #if os(macOS)
    func makeNSView(context: Context) -> MoleculeRenderer { makeView(context: context) }
    func updateNSView(_ uiView: MoleculeRenderer, context: Context) { updateView(uiView, context: context) }
    #else
    func makeUIView(context: Context) -> MoleculeRenderer { makeView(context: context) }
    func updateUIView(_ uiView: MoleculeRenderer, context: Context) { updateView(uiView, context: context) }
    #endif
    
    // AtomRenderer class as the coordinator for the SceneKit representable. To handle taps, gestures...
    func makeCoordinator() -> MoleculeRenderer {
        return controller
    }
    
    private func makeView(context: Context) -> MoleculeRenderer {
        
        // Gesture recognizer for placing atoms, bonds... Same for iPadOS and macOS
        let tapGesture = TapGesture(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        controller.addGestureRecognizer(tapGesture)
        
        
        setupGestures(context: context, renderer: controller)
        
        return controller
    }
    
    private func updateView(_ uiView: MoleculeRenderer, context: Context) {
        uiView.backgroundColor = settings.colorSettings.backgroundColor.uColor
    }
    
    #if os(macOS)
    private func setupGestures(context: Context, renderer: MoleculeRenderer) {
        let leftClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        leftClickPanGesture.buttonMask = 1
        let rightClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        rightClickPanGesture.buttonMask = 2
        controller.addGestureRecognizer(rightClickPanGesture)
        controller.addGestureRecognizer(leftClickPanGesture)
    }
    #elseif os(iOS)
    private func setupGestures(context: Context, renderer: MoleculeRenderer) {
        let panG = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        controller.addGestureRecognizer(panG)
        let pinchG = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(sender:)))
        controller.addGestureRecognizer(pinchG)
        //Temporary disabled
        let rotateG = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleZAxisRotation(sender:)))
        controller.addGestureRecognizer(rotateG)
    }
    #endif
}
