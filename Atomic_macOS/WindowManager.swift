//
//  WindowManager.swift
//  Atomic_macOS
//
//  Created by Christian Dominguez on 9/1/22.
//

import SwiftUI
import AppKit

class WindowManager: NSObject, ObservableObject {
    
    static let shared = WindowManager()
    
    @Published var currentController: MoleculeViewModel? = nil
    var openedWindows = Set<AtomicWindow>()
    let commandController = CommandMenuController.shared
    
    func updateCommands() {
        guard let currentController = currentController else {return}
        let freqWindow = currentController.renderer?.showingStep.frequencys?.isEmpty
        if let freqWindow = freqWindow {
            commandController.hasfreq = !freqWindow
        } else {
            commandController.hasfreq = false
        }
        
        
        
    }
}

extension WindowManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? AtomicWindow {
            self.openedWindows.remove(window)
            self.currentController?.openedWindows.removeAll(where: {$0 == window.windowType} )
        }
    }
    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? AtomicWindow {
            self.currentController = window.associatedController
        }
    }
}

extension View {
    private func newWindowInternal(with title: String, and type: WindowTypes) -> AtomicWindow {
        let window = AtomicWindow(
            contentRect: NSRect(x: 20, y: 20, width: 680, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        window.windowType = type
        window.center()
        window.isReleasedWhenClosed = false
        window.title = title
        window.makeKeyAndOrderFront(nil)
        return window
    }
    
    func openNewWindow(with title: String = "New Window", and type: WindowTypes = .multiple, controller: MoleculeViewModel? = nil) {
        
        if type != .multiple {
            if let controller = controller {
                if controller.openedWindows.contains(type) {
                    if let window = WindowManager.shared.openedWindows.first(where: {$0.windowType == type}) {
                        window.becomeKey()
                        window.orderFrontRegardless()
                        return
                    }
                }
                controller.openedWindows.append(type)
            }
        }
        
        let newWindow = self.newWindowInternal(with: title, and: type)
        newWindow.associatedController = controller
        newWindow.contentView = NSHostingView(rootView: self)
        newWindow.delegate = WindowManager.shared
        WindowManager.shared.openedWindows.insert(newWindow)
    }
}

class AtomicWindow: NSWindow {
    var windowType: WindowTypes = .multiple
    var associatedController: MoleculeViewModel? = nil
}

enum WindowTypes: CaseIterable {
    case ptable
    case freqs
    case outputfile
    case inputfile
    case multiple
}

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
            WindowManager.shared.updateCommands()
        }
        
    }
}
