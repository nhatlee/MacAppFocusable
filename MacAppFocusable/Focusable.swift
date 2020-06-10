//
//  Focusable.swift
//  MacAppFocusable
//
//  Created by nhatle on 6/9/20.
//  Copyright © 2020 VNG. All rights reserved.
//

import SwiftUI

extension View {
    func focusableWithClick(focusIndex: Int = 0) -> some View {
        return Focusable(focusIndex: focusIndex) { self }
    }
}

struct SelectedFocusIndexKey: EnvironmentKey {
    public static let defaultValue: Binding<Int> = Binding<Int>(get: { return 0 }, set: { _ in })
}

extension EnvironmentValues {
    var selectedFocusIndex: Binding<Int> {
        get { self[SelectedFocusIndexKey.self] }
        set { self[SelectedFocusIndexKey.self] = newValue }
    }
}

struct Focusable<Content>: View where Content : View {
    @Environment(\.selectedFocusIndex) var selectedIndex
    
    let content: () -> Content
    let focusIndex: Int
    
    init(focusIndex: Int, @ViewBuilder content: @escaping () -> Content) {
        self.focusIndex = focusIndex
        self.content = content
    }
    
    var body: some View {
        let onFocusChange: (Bool) -> Void = { isFocused in
            DispatchQueue.main.async {
                if isFocused {
                    self.selectedIndex.wrappedValue = self.focusIndex
                } else {
                    self.selectedIndex.wrappedValue = 0
                }
            }
        }
        
        let v = self.content().focusable(onFocusChange: onFocusChange)
        
        return MyRepresentable(focusIndex: self.focusIndex, onFocusChange: onFocusChange, content: v)
    }
}

struct MyRepresentable<Content>: NSViewRepresentable where Content: View {
    @Environment(\.selectedFocusIndex) var selectedIndex
    @State private var lastValue = 0
    
    let focusIndex: Int
    let onFocusChange: (Bool) -> Void
    let content: Content
    
    func makeNSView(context: Context) -> NSHostingView<Content> {
        return FocusableNSHostingView(rootView: self.content, focusIndex: self.focusIndex, onFocusChange: onFocusChange)
    }
    
    func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
        let hostingView = (nsView as! FocusableNSHostingView)
        
        if self.selectedIndex.wrappedValue == hostingView.focusIndex, self.selectedIndex.wrappedValue != self.lastValue {
            DispatchQueue.main.async {
                self.lastValue = self.selectedIndex.wrappedValue
                hostingView.claimFocus()
            }
        } else if self.lastValue != 0, self.selectedIndex.wrappedValue == 0 {
            DispatchQueue.main.async {
                self.lastValue = self.selectedIndex.wrappedValue
                hostingView.clearFocus()
            }
        } else {
            DispatchQueue.main.async {
                self.lastValue = self.selectedIndex.wrappedValue
            }
        }
    }
}

class FocusableNSHostingView<Content>: NSHostingView<Content> where Content : View {
    
    let focusIndex: Int
    let onFocusChange: (Bool) -> Void
    
    init(rootView: Content, focusIndex: Int, onFocusChange: @escaping (Bool) -> Void) {
        self.focusIndex = focusIndex
        self.onFocusChange = onFocusChange
        super.init(rootView: rootView)
    }
    
    required init(rootView: Content) {
        fatalError("init(rootView:) has not been implemented")
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        self.claimFocus()
        
        super.mouseDown(with: event)
    }
    
    func claimFocus() {
        // Here's the magic!
        // Find the NSView that should receive the focus and make it the first responder.
        
        // By experimentation, the view's class name is something like this: xxxxxxxxxxxx_FocusRingView
        if let focusRingView = self.subviews.first(where: { NSStringFromClass(type(of: $0)).contains("FocusRingView") }) {
            self.window?.makeFirstResponder(focusRingView)
            self.onFocusChange(true)
        }
    }
    
    func clearFocus() {
        self.window?.makeFirstResponder(nil)
    }
}
