import Foundation
import Testing
@testable import MacFanProCore

@Suite("SMC sensor filter — battery keys and die placeholders")
struct SMCSensorFilterTests {
    private let m4MaxBattery: Set<String> = ["TG0B", "TG0C", "TG0H", "TG0V", "TG1B", "TG2B"]

    @Test("Keys the machine publishes as battery sensors never reach the GPU row")
    func batteryKeysRejected() {
        for key in ["TG0B", "TG0H", "TG0V"] {
            #expect(!SMCSensorFilter.accepts(key, 27.1, batteryKeys: m4MaxBattery))
        }
        // Where the same keys are not battery sensors (upstream verified them as
        // GPU on M5 Max), nothing changes.
        #expect(SMCSensorFilter.accepts("TG0B", 61.0, batteryKeys: []))
    }

    @Test("Real GPU and CPU keys pass unchanged")
    func dieSensorsAccepted() {
        for (key, value) in [("Tg05", 90.0), ("TCDX", 38.5), ("TCMb", 45.3), ("Tp06", 63.9)] as [(String, Float)] {
            #expect(SMCSensorFilter.accepts(key, value, batteryKeys: m4MaxBattery))
        }
    }

    @Test("Die placeholders below the floor are rejected; 40.0 is kept")
    func diePlaceholders() {
        for value: Float in [1.5, 1.9, 5.2] {
            #expect(!SMCSensorFilter.accepts("Tp01", value, batteryKeys: []))
        }
        // Indistinguishable from a real reading, so deliberately accepted.
        #expect(SMCSensorFilter.accepts("Tp01", 40.0, batteryKeys: []))
        #expect(SMCSensorFilter.accepts("Tp01", SMCSensorFilter.minimumDieTemperature, batteryKeys: []))
    }

    @Test("Non-die sensors may legitimately read cold")
    func coldAmbientAccepted() {
        for key in ["TAOL", "TB0T", "TH0x", "TN0n"] {
            #expect(SMCSensorFilter.accepts(key, 4.0, batteryKeys: []))
        }
    }

    @Test("LocationID decodes to its four-character key")
    func locationDecoding() {
        #expect(SMCSensorFilter.fourCharKey(1_413_951_555) == "TG0C")
        #expect(SMCSensorFilter.fourCharKey(1_414_410_350) == "TN0n")
        #expect(SMCSensorFilter.fourCharKey(0) == nil)
    }

    @Test("On this Mac the HID lookup agrees with the recorded battery keys", .enabled(if: isMac16_5))
    func liveBatteryLookup() {
        #expect(Set(["TG0B", "TG0H", "TG0V"]).isSubset(of: SMCSensorFilter.batteryKeys))
    }
}

private var isMac16_5: Bool {
    var size = 0
    sysctlbyname("hw.model", nil, &size, nil, 0)
    var model = [CChar](repeating: 0, count: size)
    sysctlbyname("hw.model", &model, &size, nil, 0)
    return String(cString: model) == "Mac16,5"
}
