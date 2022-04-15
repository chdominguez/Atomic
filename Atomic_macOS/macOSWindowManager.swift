//
//  WindowManager.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 9/1/22.
//

import SwiftUI
import AppKit

/// This class manages instances of MoleculeViewModel across different windows under macOS
class MacOSWindowManager: NSObject, ObservableObject {
    
    static let shared = MacOSWindowManager()
    
    @Published var activeController: AtomicMainController? = nil
    
    var periodicTable: NSWindow? = nil
    
    var openedWindows = Set<AtomicWindow>()
    
}

//MARK: WindowManager delegate
extension MacOSWindowManager: NSWindowDelegate {
    
    func windowDidBecomeMain(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            activeController = openedWindows.first
            { $0.window == window }?.associatedController
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            
            if window.title == AtomicWindow.WindowType.ptable.rawValue {
                return // If the window is the periodic table, do nothing. The periodic table window can then be reopened again in openPTableinWindow()
            }
            
            let atomicWindow = openedWindows.first { aWindow in
                aWindow.window == window
            }
            openedWindows.remove(atomicWindow!) // The window must exsit. If not, better to crash the app.
        }
    }
}

//MARK: WindowAccessor
/// SwiftUI workaround to access underlying NSWindow on SwiftUI macOS windows. Indispensable for getting the NSWindow that hosts the MainWindow view
struct WindowAccessor: NSViewRepresentable {
    
    let associatedController: AtomicMainController
    @ObservedObject var windowManager = MacOSWindowManager.shared
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            let atomicWindow = AtomicWindow(window: view.window!, type: .mainWindow, controller: associatedController)
            atomicWindow.window.delegate = windowManager
            windowManager.openedWindows.insert(atomicWindow)
            windowManager.activeController = associatedController
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
}

//MARK: AtomicWindow
/// Custom class for tracking the active controller on cliking multiple windows
class AtomicWindow: Hashable {
    
    let window: NSWindow
    let windowType: WindowType
    let associatedController: AtomicMainController
    
    init(window: NSWindow, type: WindowType, controller: AtomicMainController) {
        self.window = window
        self.associatedController = controller
        self.windowType = type
        self.window.title = type.rawValue
    }
    
    static func == (lhs: AtomicWindow, rhs: AtomicWindow) -> Bool {
        lhs.window.windowNumber == rhs.window.windowNumber
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(window.windowNumber)
    }
    
    /// Window types. This enum allows for keeping track of already opened windows for each controller. Making it easir to bring them back instead of creating a new one. RawValue is the window title.
    public enum WindowType: String {
        case energyGraph = "Energy"
        case vibrations = "Vibrations"
        case mainWindow = "Atomic"
        
        case ptable = "Periodic table"
    }
    
}

//MARK: openNewWindow for macOS

extension View {
    
    func openNewWindow(type: AtomicWindow.WindowType? = nil, controller: AtomicMainController? = nil) {
        openNewMacOSWindow(type: type, controller: controller)
    }
    
    /// Checks if there is already an opened window for the type of window trying to open
    private func openNewMacOSWindow(type: AtomicWindow.WindowType?, controller: AtomicMainController? = nil) {
        
        guard let type = type else {
            openPTableinWindow()
            return
        }
        
        guard let controller = controller else {
            return
        }
        
        let openedWindows = MacOSWindowManager.shared.openedWindows
        if let alreadyOpened = openedWindows.first(where: { window in
            window.windowType == type && window.associatedController.id == controller.id}) {
            alreadyOpened.window.makeMain()
            return
        }
        newWindowInternal(type: type, controller: controller)
    }
    
    /// Internal function for opening windows. The actual window is created by this function
    private func newWindowInternal(type: AtomicWindow.WindowType, controller: AtomicMainController) {
        let atomicWindow = AtomicWindow(window: NSWindow(), type: type, controller: controller)
        atomicWindow.window.center()
        atomicWindow.window.isReleasedWhenClosed = false
        atomicWindow.window.title = type.rawValue
        atomicWindow.window.delegate = MacOSWindowManager.shared
        MacOSWindowManager.shared.openedWindows.insert(atomicWindow)
    }
    
    private func openPTableinWindow() {
        
        let manager = MacOSWindowManager.shared
        
        if let window = manager.periodicTable {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let window = NSWindow(contentRect: NSRect(x: 20, y: 20, width: 800, height: 600),
        styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
        backing: .buffered,
        defer: false)
        
        window.center()
        window.title = AtomicWindow.WindowType.ptable.rawValue
        window.delegate = MacOSWindowManager.shared
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        
        window.contentView = NSHostingView(rootView: self)
        
        manager.periodicTable = window
        
    }
}

