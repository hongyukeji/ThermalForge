import Testing
@testable import MacFanProCore

@Suite("Displayed CPU temperature — cores, not hotspot keys")
struct DisplayedTemperatureTests {
    private func status(_ temps: [String: Float]) -> ThermalStatus {
        ThermalStatus(fans: [], temperatures: temps)
    }

    // Captured together on Mac16,5 (M4 Max) during a Metal-only load, while
    // Stats showed hottest CPU 62.3 and hottest GPU 68.7.
    private let m4GPULoad: [String: Float] = [
        "TCDX": 73.1, "TCMb": 71.7,
        "Tp06": 75.2, "Tp02": 67.6, "Tp0A": 67.2,
        "Tp01": 61.3, "Tp05": 60.4, "Tp09": 61.9, "Tp0D": 62.3, "Tp0b": 59.8, "Tp0e": 60.1,
        "Te05": 61.4, "Te0S": 62.0,
        "Tg05": 69.0, "Tg0L": 63.2,
    ]

    @Test("On M4 the CPU row reads the core keys, not Tp06 or TCDX")
    func m4GPULoadMatchesStats() {
        let s = status(m4GPULoad)
        #expect(s.cpuTemp(coreKeys: ThermalStatus.m4CoreKeys) == 62.3)
        // Fan control and the safety floor still see the hotspot, as upstream.
        #expect(s.safetyPeakTemp == 75.2)
    }

    @Test("Without a key table the per-core prefixes are used")
    func prefixFallback() {
        #expect(status(m4GPULoad).cpuTemp(coreKeys: []) == 75.2)
    }

    @Test("A table whose keys are all absent falls back rather than going empty")
    func tableKeysAbsent() {
        let s = status(["Tp0X": 58.0, "TCDX": 70.0])
        #expect(s.cpuTemp(coreKeys: ThermalStatus.m4CoreKeys) == 58.0)
    }

    @Test("A Mac with only aggregate TC keys still shows a CPU value")
    func aggregateOnly() {
        #expect(status(["TCDX": 55.0, "Tg05": 50.0]).cpuTemp(coreKeys: ThermalStatus.m4CoreKeys) == 55.0)
    }

    @Test("Headline is the hotter displayed row")
    func headline() {
        let s = status(["Tp01": 61.3, "Tg05": 69.0, "TCDX": 80.0])
        let cpu = s.displayedCPUTemp ?? 0
        #expect(s.displayedPeakTemp == max(cpu, 69.0))
    }

    @Test("No CPU or GPU sensors leaves the rows and headline empty")
    func empty() {
        let s = status(["TH0x": 31.0, "TAOL": 25.0])
        #expect(s.displayedCPUTemp == nil)
        #expect(s.displayedGPUTemp == nil)
        #expect(s.displayedPeakTemp == nil)
    }
}
