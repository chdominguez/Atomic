
// Custom view representables. Usually, the AppKit/UIKit counterparts of SwiftUI views are faster.

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
        
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        cameraNode.camera = camera
        
        controller.sceneView.pointOfView = cameraNode
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

struct TextEditorView: Representable {
    
    let text: String
#if os(iOS)
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.textStorage.append(NSAttributedString(string: text))
        textView.isEditable = false
        textView.textColor = .label
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {}
    
#elseif os(macOS)
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as? NSTextView
        guard let _ = textView else {return NSScrollView()}
        textView!.textStorage?.append(NSAttributedString(string: text))
        textView!.isEditable = false
        textView?.textColor = .labelColor
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        
    }
#endif

    
}
