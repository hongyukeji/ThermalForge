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
                let images = [" 49", " 88", "100", "212"].map {
                    StatusItemRenderer.make(symbol: symbol, needsDot: needsDot, field: $0)
                }
                #expect(images.allSatisfy { $0.size == images[0].size })
                #expect(images.allSatisfy { $0.size.width > 0 && $0.size.height > 0 })
                #expect(images.allSatisfy { $0.tiffRepresentation != nil })
                #expect(images.allSatisfy { $0.isTemplate == !needsDot })
            }
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
