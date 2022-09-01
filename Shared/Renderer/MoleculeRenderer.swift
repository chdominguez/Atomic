//
//  SharedRenderer.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/12/21.
//
import SwiftUI
import SceneKit
import SCNLine
import ProteinKit
import MeshGenerator

/// Controls the SceneKit SCNView. Renders the 3D atoms, bonds, handles tap gestures...
class MoleculeRenderer: SCNView, ObservableObject {
    
    //MARK: Init
    
    internal let settings = GlobalSettings.shared
    
    let geometries = AtomGeometries(colors: ProteinColors())
    
    /// The steps to display
    let steps: [Step]
    
    let moleculeName: String
    
    /// The current step showed
    var showingStep: Step {
        steps[stepToShow - 1]
    }
    
    init(_ steps: [Step], moleculeName: String?) {
        self.steps = steps
        self.moleculeName = moleculeName ?? "Molecule"
        super.init(frame: .zero, options: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Step control
    
    /// For moving the steps in sequential order
    internal var timer = Timer()
    
    @Published var isStepPlaying = false
    @Published var playBack = 25
    @Published var stepToShow = 1 {
        didSet {
            moveNodes(toStep: steps[stepToShow - 1])
        }
    }
    
    //MARK: Scene
    let colors = ProteinColors()
    var atomNodes = SCNNode()
    var vdwNodes = SCNNode()
    var bondNodes = SCNNode()
    var backBoneNode = SCNLineNode()
    var cartoonNodes = SCNNode()
    var selectionNodes = SCNNode()
    var compoundAtomNodes = SCNNode()
    
    let atomicRootNode = SCNNode()
    var cameraNode = SCNNode()
    var lightNode = SCNNode()
    var light = SCNLight()
    @Published var isLightFixed: Bool = false
    
    internal var currentPivotPosition: SCNVector3 = .zero
    
    /// An array of tuples. The nodes selected with its selection orb node.
    @Published var selectedAtoms: [(selectedNode: SCNNode, selectionOrb: SCNNode)] = [] {
        didSet {
            withAnimation {
                measureNodes()
            }
        }
    }
    
    /// Turns to true when loadScenes() has finished
    @Published var didLoadAtoms = false
    
    
    /// Loads the first step and places the child nodes in the scene
    func loadScenes(moleculeName: String) {
        guard let firstStep = steps.first else {fatalError("Here a step should be present")}
        if firstStep.molecule == nil { // in case we start with a new file
            firstStep.molecule = Molecule()
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                setupBasicSCN()
                try setupScene(firstStep, moleculeName: moleculeName)}
            catch {
                fatalError()
            }
            DispatchQueue.main.sync {
                didLoadAtoms = true
            }
        }
    }
    
    /// Maybe this function is not needed...
    func resetRenderer() {
        didLoadAtoms = false
        stepToShow = 1
        selectedAtoms.removeAll()
    }
    
    //MARK: Setup scene
    
    // Setup SceneKit, Camera and Light
    
    internal func setupBasicSCN() {
        
        let scene = SCNScene()
        
        // Setup the camera node
        self.cameraNode = setupCameraNode()
        self.lightNode = setupLight()
        settings.lightNode = self.lightNode
        cameraNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        self.pointOfView = self.cameraNode
        
        self.scene = scene
        
    }
    
    /// Populates the SCNodes with atoms and bonds from the step molecule
    internal func setupScene(_ step: Step, moleculeName: String) throws {
        
        guard let molecule = steps.first?.molecule else {return}
        
        let positions = molecule.atoms.map {$0.position}
        let averagePos = averageDistance(of: positions)
        
        compoundAtomNodes.position = -averagePos
        
        //atomicRootNode.pivot = SCNMatrix4MakeTranslation(averagePos.x, averagePos.y, averagePos.z)
        // Add more space to entirely see the molecule. 10 is an okay value
        cameraNode.position.z = viewingZPosition(toSee: positions) + 10
        
        atomicRootNode.name = "Atomic root node"
        
        scene!.rootNode.addChildNode(atomicRootNode)
        
        atomicRootNode.addChildNode(compoundAtomNodes)
        
        guard let molecule = step.molecule else {return}
        
        atomNodes.name = "atoms"
        bondNodes.name = "bonds"
        backBoneNode.name = "backBone"
        cartoonNodes.name = "cartoon"
        selectionNodes.name = "selections"
        
        print(moleculeName)
        
        let kit = ProteinKit(residues: step.res, colorSettings: settings.colorSettings, moleculeName: moleculeName)
        
        if step.isProtein {
            loadCartoon(step.res)
//            atomNodes.isHidden = true
        } else {
            kit.atomNodes(atoms: molecule.atoms, to: atomNodes, hidden: false)
        }
        
        
        // Add the newly created atomNodes to the root scene
        compoundAtomNodes.addChildNode(atomNodes)
        
        // Cylinders cause a significant drop in performance.If more than 1000 bonds are present. They become a flattened cone. The downside of this is that they are converted to a big node hence individual bonds cannot be broken
        if bondNodes.childNodes.count > 1000 {
            self.bondNodes = bondNodes.flattenedClone()
        }
        
        compoundAtomNodes.addChildNode(bondNodes)
        
        // Add selection node as child of the main node
        
        compoundAtomNodes.addChildNode(selectionNodes)
        
    }
    
    enum BondType: String {
        case single = "Single"
        case double = "Double"
        case triple = "Triple"
        
        var symbol: String {
            switch self {
            case .single:
                return "line.diagonal"
            case .double:
                return "equal"
            case .triple:
                return "line.3.horizontal"
            }
        }
    }
    
    @Published var currentBondType: BondType = .single
    
    //MARK: Tools
    
    @Published var showSidebar = false
    
    /// Available tools
    enum Tools {
        case addAtom
        case removeAtom
        case selectAtom
    }

    /// Selected tool on this scene
    @Published var selectedTool: Tools = .selectAtom
    
    //MARK: Selection
    
    /// Distance of selected nodes
    @Published var measuredDistangle: String = ""
    @Published var showDistangle: Bool = false
    
    /// Shows Angstroms or degrees depending on the number of selected atoms
    var currentUnit: String = " Å"
    
    var maxRange: ClosedRange<Double> {
        if selectedAtoms.count == 3 {
            return 0.5...180
        }
        return 0.5...5
    }
    
    var bindingDoubleDistangle: Binding<Double> {
        Binding { [self] in
            filterStoD(measuredDistangle, maxValue: maxRange.upperBound, minValue: maxRange.lowerBound)
        } set: {self.measuredDistangle = $0.stringWith(3) + self.currentUnit; self.editDistanceOrAngle()}

    }
    
    //MARK: Camera controls
    internal var previousPanTranslation: Point? = nil
    internal var previousLoc = CGPoint.init(x: 0, y: 0)
    internal var optionPressed: Bool = false
    internal var controlPressed: Bool = false
    internal var prevRotation: UFloat = .zero
}

extension PanGesture {
    #if os(macOS)
    var integer: Int {self.buttonMask}
    #elseif os(iOS)
    var integer: Int {self.numberOfTouches}
    #endif
 }

//MARK: MoleculeRenderer extension for node types
extension MoleculeRenderer {
    enum AtomicNodeTypes: String, CaseIterable {
        case atom = "A"
        case bond = "B"
        case cartoon = "C"
        case selection = "S"
        case void = ""
    }
    
    func getNodeType(_ hitNode: SCNNode) -> AtomicNodeTypes? {
        guard let name = hitNode.name?.split(separator: "_")[0] else {return nil}
        for t in AtomicNodeTypes.allCases {
            if t.rawValue == name {
                return t
            }
        }
        return nil
    }
}

// Custom view representables. Usually, the AppKit/UIKit counterparts of SwiftUI views are faster and more customizable.

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
    
    internal func makeView(context: Context) -> MoleculeRenderer {
        
        // Gesture recognizer for placing atoms, bonds... Same for iPadOS and macOS
        let tapGesture = TapGesture(target: context.coordinator, action: #selector(Coordinator.handleTaps(gesture:)))
        controller.addGestureRecognizer(tapGesture)
        
        
        setupGestures(context: context, renderer: controller)
        
        return controller
    }
    
    internal func updateView(_ uiView: MoleculeRenderer, context: Context) {
        uiView.backgroundColor = settings.colorSettings.backgroundColor.uColor
    }
    
    #if os(macOS)
    internal func setupGestures(context: Context, renderer: MoleculeRenderer) {
        let leftClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        leftClickPanGesture.buttonMask = 1
        let rightClickPanGesture = PanGesture(target: context.coordinator, action: #selector(Coordinator.handlePan(sender:)))
        rightClickPanGesture.buttonMask = 2
        controller.addGestureRecognizer(rightClickPanGesture)
        controller.addGestureRecognizer(leftClickPanGesture)
    }
    #elseif os(iOS)
    internal func setupGestures(context: Context, renderer: MoleculeRenderer) {
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
