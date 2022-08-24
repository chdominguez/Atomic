//
//  CameraLights.swift
//  Atomic
//
//  Created by Christian Dominguez on 9/8/22.
//

import ProteinKit
import SceneKit

extension MoleculeRenderer {
    
    internal func setupCameraNode() -> SCNNode {
        let cam = SCNCamera()
        cam.name = "camera"
        cam.zFar = 200
        cam.zNear = 0.1
        let camNode = SCNNode()
        camNode.camera = cam
        camNode.position = SCNVector3(0, 0, 5)
        camNode.name = "Camera node"
        camNode.light = setupLight()
        return camNode
    }
    
    internal func setupLight() -> SCNLight {
        let light = SCNLight()
        light.color = UColor.white
        light.intensity = 800
        light.type = .directional
        
//        let lnode = SCNNode()
//        lnode.light = light
//        lnode.position = SCNVector3Make(0, 0, 0)
//        lnode.name = "Light node"
        return light
    }
    
    func zoomCamera(_ inOrOut: Bool) {
        let proportion = cameraNode.position.z
        if inOrOut {
            cameraNode.runAction(SCNAction.move(to:cameraNode.position - SCNVector3(0,0,0.25*proportion), duration: 0.1))
        }
        else {
            cameraNode.runAction(SCNAction.move(to: cameraNode.position + SCNVector3(0,0,0.25*proportion), duration: 0.1))
        }
    }
    
    #if os(macOS)
    typealias Point = NSPoint
    #elseif os(iOS)
    typealias Point = CGPoint
    #endif
    
    // Save code for rotate molecules etc...
    internal func rotate(sender recognizer: PanGesture)
    {
        switch recognizer.state
        {
        case .began:
            self.previousPanTranslation = .zero
        case .changed:
            guard let previous = self.previousPanTranslation else
            {
                //previousPanTranslation = .zero
                return
            }
            // Calculate how much translation occurred between this step and the previous step
            let translation = recognizer.translation(in: self)
            let translationDelta = CGPoint(x: translation.x - previous.x, y: translation.y - previous.y)
            // Use the pan translation along the x axis to adjust the camera's rotation about the y axis.
            let yScalar = Float(translationDelta.x / self.bounds.size.width)
            let yRadians = yScalar * 2//* self.dynamicType.MaxPanGestureRotation
            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis.
            let xScalar = Float(translationDelta.y / self.bounds.size.height)
            var xRadians = xScalar * 2//* self.dynamicType.MaxPanGestureRotation
            #if os(macOS)
            xRadians = -xRadians
            #endif
            // Use the radian values to construct quaternions
            let x = GLKQuaternionMakeWithAngleAndAxis(xRadians, 1, 0, 0)
            let y = GLKQuaternionMakeWithAngleAndAxis(yRadians, 0, 1, 0)
            let z = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1)
            let combination = GLKQuaternionMultiply(z, GLKQuaternionMultiply(y, x))
            // Multiply the quaternions to obtain an updated orientation
            let scnOrientation = self.atomicRootNode.orientation
            let glkOrientation = GLKQuaternionMake(Float(scnOrientation.x), Float(scnOrientation.y), Float(scnOrientation.z), Float(scnOrientation.w))
            let q = GLKQuaternionMultiply(combination, glkOrientation)
            // And finally set the current orientation to the updated orientation
            self.atomicRootNode.orientation = SCNQuaternion(x: UFloat(q.x), y: UFloat(q.y), z: UFloat(q.z), w: UFloat(q.w))
            self.previousPanTranslation = translation
        default:
            self.previousPanTranslation = nil
            break
        }
    }

    
    internal func moveCamera(sender: PanGesture) {
        var delta = sender.translation(in: self)
        let loc = sender.location(in: self)
        
        if sender.state == .changed {
            delta = CGPoint.init(x: 2 * (loc.x - previousLoc.x), y: 2 * (loc.y - previousLoc.y))
            #if os(iOS)
            delta.y = -delta.y
            #endif
            atomicRootNode.position = SCNVector3(atomicRootNode.position.x + UFloat(delta.x * 0.02), atomicRootNode.position.y + UFloat(delta.y * (0.02)), 0)
            previousLoc = loc
        }
        previousLoc = loc
    }
    
    
    @objc func handlePan(sender: PanGesture) {
        #if os(macOS)
        macOSCameraControls(sender: sender)
        #elseif os(iOS)
        iosCameraControls(sender: sender)
        #endif
    }
    
    #if os(iOS)
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            var move = sender.scale
            if move < 1 { move = -1/move }
            if cameraNode.position.z <= 5 && 1/sender.scale < 1 { return }
            cameraNode.position.z += UFloat(-move*0.2)
        }
    }
    
    //Rotates the camera around the Z axis
    //var prevRotation: UFloat = .zero
    @objc func handleZAxisRotation(sender: UIRotationGestureRecognizer) {
        if sender.state == .changed {
            let newRotation = prevRotation + UFloat(-sender.rotation)
            cameraNode.eulerAngles.z = newRotation
        }
        if sender.state == .ended {
            prevRotation = cameraNode.eulerAngles.z
            let circles = prevRotation / UFloat((2*Double.pi))
            // If the rotation has achieved more than 1 circle, substract the circle to always be in range of 0~2pi
            if abs(circles) > 1 {
                prevRotation -= UFloat(2*Double.pi) * circles.rounded(.down)
            }
        }
    }
    
    internal func iosCameraControls(sender: PanGesture) {
        if sender.numberOfTouches <= 1 {
            rotate(sender: sender)
            return
        }
        if sender.numberOfTouches == 2 {
            moveCamera(sender: sender)
        }
    }
    #endif
    
    internal func macOSCameraControls(sender: PanGesture) {
        if sender.integer == 1 {
            rotate(sender: sender)
            return
        }
        if sender.integer == 2 {
            moveCamera(sender: sender)
            return
        }
    }
    
    func resetPivot() {
        let positions = steps.first?.molecule?.atoms.map {$0.position}
        guard let positions = positions else {return}
        let nodePos = averageDistance(of: positions)
        let cameraPos = viewingZPosition(toSee: positions) + 10

        atomicRootNode.pivot = SCNMatrix4MakeTranslation(nodePos.x, nodePos.y, nodePos.z)
        let moveAction = SCNAction.move(to: .zero, duration: 0.2)
        let moveCam = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: cameraPos), duration: 0.2)
        atomicRootNode.runAction(moveAction)
        //cameraOrbit.runAction(moveAction)
        cameraNode.runAction(moveCam)
    }
    
    func makeSelectedPivot() {
        guard let node = selectedAtoms.first?.selectedNode else {return}
        var newPos = node.position
        if node.name!.starts(with: "C_") {newPos = node.boundingSphere.center}
        
        
        
        self.atomicRootNode.pivot = SCNMatrix4MakeTranslation(newPos.x, newPos.y, newPos.z)
    }
    

    
#if os(macOS)
    internal func rotateZAxismacOS(scroll: UFloat) {
        
        let scaledScroll = scroll * 0.01
        let newRotation = prevRotation + UFloat(-scaledScroll)
        cameraNode.eulerAngles.z = newRotation
        let circles = newRotation / UFloat((2*Double.pi))
        // If the rotation has achieved more than 1 circle, substract the circle to always be in range of 0~2pi
        if abs(circles) > 1 {
            prevRotation -= UFloat(2*Double.pi) * circles.rounded(.down)
        }
    }

    
    override func flagsChanged(with event: NSEvent) {
        if event.keyCode == 58 {
            optionPressed.toggle()
            return
        }
        if event.keyCode == 59 {
            controlPressed.toggle()
            return
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        let isClunkyMouse = !event.hasPreciseScrollingDeltas
        let scalingForClunky: UFloat = isClunkyMouse ? 2.5 : 1
        if event.phase == .changed || isClunkyMouse {
            if optionPressed {
                if cameraNode.position.z < 5 && event.scrollingDeltaY < 0 {
                    return
                }
                cameraNode.localTranslate(by: SCNVector3(x: 0, y: 0, z: event.scrollingDeltaY * 0.1 * scalingForClunky))
            }
            else if controlPressed {
                rotateZAxismacOS(scroll: event.scrollingDeltaY * scalingForClunky)
            }
            else {
                orbitNode.localTranslate(by: SCNVector3(x: 0, y: -event.scrollingDeltaY * scalingForClunky/50, z: 0))
                orbitNode.localTranslate(by: SCNVector3(x: event.scrollingDeltaX * scalingForClunky/50, y: 0, z: 0))
            }
        }
    }
#endif
}
