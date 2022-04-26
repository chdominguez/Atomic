
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
        controller.sceneView.addGestureRecognizer(gesture)
        
        // Scene view controls
        controller.sceneView.allowsCameraControl = true
        controller.sceneView.defaultCameraController.interactionMode = .orbitCenteredArcball
        controller.sceneView.autoenablesDefaultLighting = true
        //controller.sceneView.showsStatistics = true

        // Attach the scene to the sceneview
        controller.sceneView.scene = controller.scene
        
        // Setup the camera node
        let camera = SCNCamera()
        camera.zNear = 0.5
        camera.zFar = 200
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 0, 5)
        
        controller.sceneView.pointOfView = cameraNode
        guard let molecule = controller.steps.first?.molecule else {return controller.sceneView}
        
        let positions = molecule.atoms.map {$0.position}
        cameraNode.position = averageDistance(of: positions)
        controller.sceneView.defaultCameraController.target = cameraNode.position
        
        // Add more space to entirely see the molecule. 10 is an okay value
        #if os(macOS)
        cameraNode.position.z = viewingZPositionCGFloat(toSee: positions) + 10
        #elseif os(iOS)
        cameraNode.position.z = viewingZPositionFloat(toSee: positions) + 10
        #endif
        //controller.sceneView.backgroundColor = settings.colorSettings.backgroundColor.UniversalColor
        return controller.sceneView
    }
    
    private func updateView(_ uiView: SCNView, context: Context) {
        uiView.backgroundColor = settings.colorSettings.backgroundColor.uColor
        controller.backBone.isHidden = !(settings.atomStyle == .backBone)
        controller.atomNodes.isHidden = !(settings.atomStyle == .ballAndStick)
        controller.bondNodes.isHidden = !(settings.atomStyle == .ballAndStick)
    }
    
}
