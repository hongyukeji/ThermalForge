import AppKit
import SwiftUI

/// MenuBarExtra can retain its largest window height after a banner disappears.
/// Keep its native window fitted to the content without replacing its styling.
struct MenuWindowSizing: NSViewRepresentable {
    let contentSize: CGSize

    func makeNSView(context: Context) -> SizingView { SizingView() }

    func updateNSView(_ view: SizingView, context: Context) {
        view.contentSize = contentSize
        view.scheduleResize()
    }

    final class SizingView: NSView {
        var contentSize = CGSize.zero
        private var resizePending = false

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            scheduleResize()
        }

        func scheduleResize() {
            guard !resizePending else { return }
            resizePending = true
            // Apply after SwiftUI's layout pass, not while updating the view tree.
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.resizePending = false
                self.resizeWindow()
            }
        }

        private func resizeWindow() {
            guard let window, contentSize.width > 0, contentSize.height > 0 else { return }
            let size = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize)).size
            let frame = window.frame
            guard abs(frame.width - size.width) > 0.5 || abs(frame.height - size.height) > 0.5 else { return }
            // Anchor the top edge below the menu bar while the bottom moves.
            window.setFrame(NSRect(x: frame.minX, y: frame.maxY - size.height,
                                   width: size.width, height: size.height), display: true)
        }
    }
}
