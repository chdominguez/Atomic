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
    
    var openedWindows = Set<AtomicWindow>()
}

extension WindowManager: NSWindowDelegate {
  func windowWillClose(_ notification: Notification) {
      if let window = notification.object as? AtomicWindow {
          WindowManager.shared.openedWindows.remove(window)
      }
  }
  func windowDidBecomeKey(_ notification: Notification) {
    if let _ = notification.object as? AtomicWindow {
      print("Did become key")
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
    
    func openNewWindow(with title: String = "New Window", and type: WindowTypes = .multiple) {
        
        if type != .multiple {
            if let window = WindowManager.shared.openedWindows.first(where: {$0.windowType == type}) {
                window.becomeKey()
                window.orderFrontRegardless()
                return
            }
        }
        
        let newWindow = self.newWindowInternal(with: title, and: type)
        newWindow.contentView = NSHostingView(rootView: self)
        newWindow.delegate = WindowManager.shared
        WindowManager.shared.openedWindows.insert(newWindow)
    }
}

class AtomicWindow: NSWindow {
    var windowType: WindowTypes = .multiple
}

enum WindowTypes: CaseIterable {
    case ptable
    case multiple
}
