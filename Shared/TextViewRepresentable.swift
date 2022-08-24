//
//  TextViewRepresentable.swift
//  Atomic
//
//  Created by Christian Dominguez on 11/4/22.
//

import SwiftUI

// Text editor from UIKit/AppKit performs a lot BETTER (for large files) than the SwiftUI counterpart.
struct TextEditorView: Representable {
    
    let text: String // Text to be displayed
    
    #if os(iOS)
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.textStorage.append(NSAttributedString(string: text))
        textView.isEditable = false
        textView.textColor = .label
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {}
    #elseif os(macOS)
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as? NSTextView
        guard let _ = textView else {return NSScrollView()}
        textView!.textStorage?.append(NSAttributedString(string: text))
        textView!.isEditable = false
        textView?.textColor = .labelColor
        return scrollView
    }
    func updateNSView(_ nsView: NSScrollView, context: Context) {}
    #endif
}
