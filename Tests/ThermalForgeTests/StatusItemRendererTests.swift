import AppKit
import Testing
@testable import ThermalForgeApp

@Suite("Status item renderer — no app launch")
@MainActor
struct StatusItemRendererTests {
    @Test("Two/three-digit temperatures and units have a stable image width")
    func stableWidth() {
        for symbol in ["fan", "fan.fill", "exclamationmark.triangle.fill"] {
            for needsDot in [false, true] {
                let images = ["49", "88", "100", "212"].map {
                    StatusItemRenderer.make(symbol: symbol, needsDot: needsDot, field: $0)
                }
                #expect(images.allSatisfy { $0.size == images[0].size })
                #expect(images.allSatisfy { $0.size.width > 0 && $0.size.height > 0 })
                #expect(images.allSatisfy { $0.tiffRepresentation != nil })
                #expect(images.allSatisfy { $0.isTemplate == !needsDot })
            }
        }
    }

    @Test("Two-digit readings start beside the icon without a hidden leading column")
    func compactDigitAlignment() throws {
        for symbol in ["fan", "fan.fill", "exclamationmark.triangle.fill"] {
            let icon = try #require(NSImage(systemSymbolName: symbol, accessibilityDescription: nil))
            func firstDigit(_ field: String) throws -> CGFloat {
                let image = StatusItemRenderer.make(symbol: symbol, needsDot: false, field: field)
                let data = try #require(image.tiffRepresentation)
                let bitmap = try #require(NSBitmapImageRep(data: data))
                let scale = CGFloat(bitmap.pixelsWide) / image.size.width
                for x in Int(ceil((icon.size.width + 3) * scale))..<bitmap.pixelsWide {
                    if (0..<bitmap.pixelsHigh).contains(where: { (bitmap.colorAt(x: x, y: $0)?.alphaComponent ?? 0) > 0.25 }) {
                        return CGFloat(x) / scale
                    }
                }
                throw CocoaError(.coderValueNotFound)
            }
            let two = try firstDigit("88")
            let three = try firstDigit("888")
            #expect(abs(two - three) <= 1)
            #expect(two - icon.size.width <= 6)
        }
    }

    @Test("Missing telemetry renders a valid accessible icon")
    func missingTemperature() {
        let image = StatusItemRenderer.make(symbol: "fan", needsDot: false, field: nil)
        #expect(image.size.width > 0)
        #expect(image.tiffRepresentation != nil)
        #expect(image.accessibilityDescription == "ThermalForge")
    }
}
