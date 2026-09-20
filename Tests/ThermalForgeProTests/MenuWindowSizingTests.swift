import AppKit
import Testing
@testable import ThermalForgeProApp

@Suite("Menu window sizing — no services")
@MainActor
struct MenuWindowSizingTests {
    @Test("Window grows and shrinks with content while retaining its top anchor")
    func changingContentHeight() async throws {
        _ = NSApplication.shared
        let window = NSWindow(contentRect: NSRect(x: 120, y: 180, width: 260, height: 449),
                              styleMask: .borderless, backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.close() }
        let sizing = MenuWindowSizing.SizingView()
        window.contentView = sizing
        let top = window.frame.maxY

        for height: CGFloat in [539, 449, 620, 449] {
            // Several SwiftUI updates in one layout pass must use the latest size.
            sizing.contentSize = CGSize(width: 260, height: height + 30)
            sizing.scheduleResize()
            sizing.contentSize = CGSize(width: 260, height: height)
            sizing.scheduleResize()
            try await Task.sleep(for: .milliseconds(30))
            #expect(window.frame.size == CGSize(width: 260, height: height))
            #expect(window.frame.maxY == top)
            #expect(window.frame.minX == 120)
        }
    }
}
