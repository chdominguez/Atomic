
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
        
        // Gesture recognizer for placing atoms, bonds...
        let tapGesture = TapGesture(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        let leftClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        leftClickPanGesture.buttonMask = 1
        let rightClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        rightClickPanGesture.buttonMask = 2
        //let key = CGEvent
        controller.addGestureRecognizer(tapGesture)
        controller.addGestureRecognizer(rightClickPanGesture)
        controller.addGestureRecognizer(leftClickPanGesture)

        
        // Scene view controls
        //controller.sceneView.allowsCameraControl = true
        //controller.sceneView.defaultCameraController.interactionMode = .orbitCenteredArcball
        //controller.sceneView.autoenablesDefaultLighting = true
        //controller.sceneView.showsStatistics = true

        // Attach the scene to the sceneview
        
        // Setup the camera node
        controller.cameraNode = setupCamera()
        controller.cameraOrbit.name = "Camera orbit"
        controller.cameraOrbit.addChildNode(controller.cameraNode)
        //controller.sceneView.pointOfView = controller.cameraOrbit
        
        // Setup light node
        controller.lightNode = setupLight()
        
        controller.cameraNode.addChildNode(controller.lightNode)
        
        controller.scene!.rootNode.addChildNode(controller.cameraOrbit)
        
        //controller.pointOfView = controller.cameraNode
        guard let molecule = controller.steps.first?.molecule else {return controller}
        
        let positions = molecule.atoms.map {$0.position}
        let averagePos = averageDistance(of: positions)
        //controller.cameraNode.position =
        //controller.defaultCameraController.target = controller.cameraNode.position
        controller.atomicNode.pivot = SCNMatrix4MakeTranslation(averagePos.x, averagePos.y, averagePos.z)
        // Add more space to entirely see the molecule. 10 is an okay value
        controller.cameraNode.position.z = viewingZPosition(toSee: positions) + 10
        
        return controller
    }
    
    private func updateView(_ uiView: MoleculeRenderer, context: Context) {
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
        camNode.name = "Camera node"
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
        lnode.name = "Light node"
        return lnode
    }
        
}
