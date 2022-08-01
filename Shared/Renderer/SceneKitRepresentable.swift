
// Custom view representables. Usually, the AppKit/UIKit counterparts of SwiftUI views are faster and more customizable.

import SwiftUI
import SceneKit

// Cross-platform APIs compatibilities
#if os(iOS)
typealias Representable = UIViewRepresentable
typealias Gesture = UITapGestureRecognizer
#elseif os(macOS)
typealias Representable = NSViewRepresentable
typealias Gesture = NSClickGestureRecognizer
#endif

struct SceneUI: Representable {
    
    @ObservedObject var controller: MoleculeRenderer
    @ObservedObject var settings = GlobalSettings.shared
    @Environment(\.colorScheme) var colorScheme
    
    #warning("BUG: Strange behaviour on zooming on Apple Silicon")
    #warning("BUG: macOS zooming different from iOS zooming. Implement custom camera movement")
    
    // View representables functions are different for each platform. Even tough the codes are exactly the same. Why Apple?
    #if os(macOS)
    func makeNSView(context: Context) -> SCNView { makeView(context: context) }
    func updateNSView(_ uiView: SCNView, context: Context) { updateView(uiView, context: context) }
    #else
    func makeUIView(context: Context) -> SCNView { makeView(context: context) }
    func updateUIView(_ uiView: SCNView, context: Context) { updateView(uiView, context: context) }
    #endif
    
    // AtomRenderer class as the coordinator for the SceneKit representable. To handle taps, gestures...
    func makeCoordinator() -> MoleculeRenderer {
        return controller
    }
    
    private func makeView(context: Context) -> SCNView {
        
        // Gesture recognizer for placing atoms, bonds...
        let gesture = Gesture(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        //let key = CGEvent
        controller.sceneView.addGestureRecognizer(gesture)
        
        // Scene view controls
        //controller.sceneView.allowsCameraControl = true
        //controller.sceneView.defaultCameraController.interactionMode = .orbitCenteredArcball
        //controller.sceneView.autoenablesDefaultLighting = true
        //controller.sceneView.showsStatistics = true

        // Attach the scene to the sceneview
        controller.sceneView.scene = controller.scene
        
        // Setup the camera node
        controller.cameraNode = setupCamera()
        
        // Setup light node
        controller.lightNode = setupLight()
        
        controller.cameraNode.addChildNode(controller.lightNode)
        
        controller.scene.rootNode.addChildNode(controller.cameraNode)
        
        controller.sceneView.pointOfView = controller.cameraNode
        guard let molecule = controller.steps.first?.molecule else {return controller.sceneView}
        
        let positions = molecule.atoms.map {$0.position}
        controller.cameraNode.position = averageDistance(of: positions)
        controller.sceneView.defaultCameraController.target = controller.cameraNode.position
        
        // Add more space to entirely see the molecule. 10 is an okay value
        controller.cameraNode.position.z = viewingZPosition(toSee: positions) + 10
        
        return controller.sceneView
    }
    
    private func updateView(_ uiView: SCNView, context: Context) {
        uiView.backgroundColor = settings.colorSettings.backgroundColor.uColor
    }
    
    private func setupCamera() -> SCNNode {
        let cam = SCNCamera()
        cam.name = "Camera"
        cam.zFar = 500
        cam.zNear = 0.01
        let camNode = SCNNode()
        camNode.camera = cam
        camNode.position = SCNVector3Make(0, 0, 5)
        return camNode
    }
    
    private func setupLight() -> SCNNode {
        let light = SCNLight()
        light.color = Color.white.uColor
        light.intensity = 150
        
        let lnode = SCNNode()
        lnode.light = light
        lnode.position = SCNVector3Make(0, 0, 0)
        return lnode
    }
        
}
