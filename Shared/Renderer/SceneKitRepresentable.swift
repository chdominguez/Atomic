
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
        let tapGesture = TapGesture(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        let leftClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        leftClickPanGesture.buttonMask = 1
        let rightClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        rightClickPanGesture.buttonMask = 2
        //let key = CGEvent
        controller.sceneView.addGestureRecognizer(tapGesture)
        controller.sceneView.addGestureRecognizer(rightClickPanGesture)
        controller.sceneView.addGestureRecognizer(leftClickPanGesture)

        
        // Scene view controls
        //controller.sceneView.allowsCameraControl = true
        //controller.sceneView.defaultCameraController.interactionMode = .orbitCenteredArcball
        //controller.sceneView.autoenablesDefaultLighting = true
        //controller.sceneView.showsStatistics = true

        // Attach the scene to the sceneview
        controller.sceneView.scene = controller.scene
        
        // Setup the camera node
        controller.cameraNode = setupCamera()
        controller.cameraOrbit.addChildNode(controller.cameraNode)
        controller.sceneView.pointOfView = controller.cameraOrbit
        
        // Setup light node
        controller.lightNode = setupLight()
        
        controller.cameraNode.addChildNode(controller.lightNode)
        
        controller.scene.rootNode.addChildNode(controller.cameraOrbit)
        
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
        cam.name = "camera"
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
        light.intensity = 800
        light.type = .directional
        
        let lnode = SCNNode()
        lnode.light = light
        lnode.position = SCNVector3Make(0, 0, 0)
        return lnode
    }
        
}
