import Testing
@testable import ThermalForgeCore

@Suite("Fan release — no hardware writes")
struct FanReleaseTests {
    @Test("A failed mode write still attempts the other fan and Ftst")
    func partialFailure() {
        var keys: [String] = []
        #expect(throws: (any Error).self) {
            try FanHandoff.release(indices: [0, 1], hasFtst: true,
                                   modeKey: { "F\($0)Md" }) { key, _ in
                keys.append(key)
                return key != "F0Md"
            }
        }
        #expect(keys == ["F0Md", "F0Tg", "F1Md", "F1Tg", "Ftst"])
    }

    @Test("A rejected Ftst reset is reported by key")
    func forceTestFailure() {
        do {
            try FanHandoff.release(indices: [0, 1], hasFtst: true,
                                   modeKey: { "F\($0)Md" }) { key, _ in key != "Ftst" }
            Issue.record("Expected the Ftst write to fail")
        } catch ThermalForgeError.writeFailed(let key) {
            #expect(key == "Ftst")
        } catch { Issue.record("Unexpected error: \(error)") }
    }

    @Test("Advisory target failures do not invalidate successful mode recovery")
    func advisoryFailure() throws {
        var keys: [String] = []
        try FanHandoff.release(indices: [0, 1], hasFtst: false,
                               modeKey: { "F\($0)md" }) { key, _ in
            keys.append(key)
            return !key.hasSuffix("Tg")
        }
        #expect(keys == ["F0md", "F0Tg", "F1md", "F1Tg"])
    }
}
