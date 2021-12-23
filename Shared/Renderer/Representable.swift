
import SwiftUI
import SceneKit

#if os(iOS)
typealias Representable = UIViewRepresentable
#elseif os(macOS)
typealias Representable = NSViewRepresentable
#endif

struct SceneUI: Representable {
    
    @ObservedObject var controller: RendererController

    #if os(macOS)
    
    func makeNSView(context: Context) -> SCNView {
        let gesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        controller.sceneView.addGestureRecognizer(gesture)
        controller.sceneView.allowsCameraControl = true
        controller.sceneView.defaultCameraController.interactionMode = .orbitTurntable
        controller.sceneView.cameraControlConfiguration.autoSwitchToFreeCamera = true
        controller.sceneView.cameraControlConfiguration.allowsTranslation = true
        controller.sceneView.autoenablesDefaultLighting = true
        controller.sceneView.scene = controller.scene
        return controller.sceneView
    }
    func updateNSView(_ uiView: SCNView, context: Context) {

    }
    
    #else
    
    func makeUIView(context: Context) -> SCNView {
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        controller.sceneView.addGestureRecognizer(gesture)
        controller.sceneView.allowsCameraControl = true
        controller.sceneView.defaultCameraController.interactionMode = .orbitTurntable
        controller.sceneView.cameraControlConfiguration.autoSwitchToFreeCamera = true
        controller.sceneView.cameraControlConfiguration.allowsTranslation = true
        controller.sceneView.autoenablesDefaultLighting = true
        controller.sceneView.scene = controller.scene
        return controller.sceneView
    }
    func updateUIView(_ uiView: SCNView, context: Context) {
    }
    
    #endif
    
    func makeCoordinator() -> AtomRenderer {
        AtomRenderer(self, controller: controller)
    }
}

