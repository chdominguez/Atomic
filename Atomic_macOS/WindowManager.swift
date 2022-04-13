//
//  WindowManager.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 9/1/22.
//

import SwiftUI
import AppKit
#warning("Remake window manager")
// This class manages instances of MoleculeViewModel across different windows under macOS
class WindowManager: NSObject, ObservableObject {
    
    static let shared = WindowManager()
    
    var openedPtable = false
    
    @Published var currentController: MoleculeViewModel? = nil
    
    let commandController = CommandMenuController.shared
    
}

extension WindowManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? AtomicWindow {
            self.currentController?.openedWindows.remove(window)
        }
    }
    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? AtomicWindow {
            self.currentController = window.associatedController
        }
    }
}

extension View {
    private func newWindowInternal(with title: String, multiple: Bool) -> AtomicWindow {
        let window = AtomicWindow(
            contentRect: NSRect(x: 20, y: 20, width: 680, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        window.multipleWindows = multiple
        window.center()
        window.isReleasedWhenClosed = false
        window.title = title
        window.makeKeyAndOrderFront(true)
        
        window.contentView = NSHostingView(rootView: self)
        //newWindow.delegate = WindowManager.shared
        
        return window
    }
    
    func windowInternalMacOS(_ title: String = "New Window", _ multiple: Bool = true, _ controller: MoleculeViewModel? = nil) {
        
        if let controller = controller {
            if multiple {
                let newWindow = newWindowInternal(with: title, multiple: multiple)
                controller.openedWindows.insert(newWindow)
            } else {
                let presentWindow = controller.openedWindows.first { window in
                    window.title == title
                }
                guard let presentWindow = presentWindow else {
                    return
                }
                presentWindow.becomeFirstResponder()
            }
        } else {
            newWindowInternal(with: title, multiple: multiple)
        }
    }
}

class AtomicWindow: NSWindow {
    var multipleWindows = true
    var associatedController: MoleculeViewModel? = nil
}


// SwiftUI workaround to access underlying NSWindow properties on SwiftUI macOS windows
struct WindowAccessor: NSViewRepresentable {
    
    let controller: MoleculeViewModel
    @State var window: NSWindow? = nil
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window!
            self.window!.delegate = context.coordinator
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSWindowDelegate {
        
        let parent: WindowAccessor
        
        init(_ parent: WindowAccessor) {
            self.parent = parent
        }
        
        func windowDidBecomeKey(_ notification: Notification) {
            WindowManager.shared.currentController = parent.controller
            //WindowManager.shared.updateCommands()
        }
        
    }
}
