import Foundation
import Testing
@testable import ThermalForgeCore

@Suite("Wake and cooldown recovery — simulated hardware")
struct RecoveryTests {
    final class Harness {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ThermalForgeRecovery-\(UUID().uuidString)")
        var temperature: Float = 40
        var mode = "auto"
        var rpm = 0
        var commands: [FanCommand] = []
        var monitor: ThermalMonitor!

        init(profile: FanProfile = .smart, calibration: CalibrationData? = nil) {
            monitor = ThermalMonitor(statusProvider: { [unowned self] in
                ThermalStatus(fans: [
                    .init(index: 0, actualRPM: rpm, targetRPM: rpm,
                          minRPM: 1400, maxRPM: 6000, mode: mode)
                ], temperatures: ["Tg0j": temperature])
            }, profile: profile, logger: TFLogger(directory: directory),
            calibrationLoader: { calibration })
            monitor.onFanCommand = { [unowned self] command in
                commands.append(command)
                switch command {
                case .resetAuto: mode = "auto"; rpm = 0
                case .setMax: mode = "manual"; rpm = 6000
                case .setRPM(let value), .setFan(_, let value): mode = "manual"; rpm = Int(value)
                }
            }
        }

        func step(_ value: Float, ticks: Int = 1) {
            temperature = value
            for _ in 0..<ticks { monitor.tick() }
        }
        deinit { try? FileManager.default.removeItem(at: directory) }
    }

    @Test("Smart releases below 50 even with stale positive temperature history")
    func coldPositiveHistory() {
        let h = Harness()
        h.step(40, ticks: 20)
        h.step(96, ticks: 20)
        #expect(h.commands.last == .setMax)
        h.step(49)
        #expect(h.commands.last == .resetAuto)
        #expect(h.monitor.state == .idle)
    }

    @Test("Calibration cannot pin a running fan high in Smart's 50–53 band")
    func calibratedCooldown() {
        let calibration = CalibrationData(machine: "simulated", fans: 1, maxRPM: 6000,
            minRPM: 1400, calibratedAt: "test", measurements: [
                .init(targetTemp: 60, holdingRPMPercent: 0.8),
                .init(targetTemp: 85, holdingRPMPercent: 1)
            ])
        let h = Harness(calibration: calibration)
        h.step(70, ticks: 300)
        #expect(h.rpm > 4000)
        h.step(51, ticks: 400)
        // The unchanged governor suppresses changes below 0.2% (12 RPM here).
        #expect(abs(h.rpm - 1400) <= 12)
        #expect(h.mode == "manual")
        h.step(49)
        #expect(h.mode == "auto")
    }

    @Test("Official Smart engagement delay and 95-degree safety remain intact")
    func smartThresholds() {
        let h = Harness()
        h.step(60, ticks: 59)
        #expect(h.commands.isEmpty)
        h.step(60)
        #expect(h.mode == "manual")
        h.step(85, ticks: 250)
        #expect(abs(h.rpm - 6000) <= 12)
        h.step(95)
        #expect(h.commands.last == .setMax)
        #expect(h.monitor.state == .safetyOverride)
    }

    @Test("Unowned manual hardware alone does not authorize clearing a CLI hold")
    func unknownManualOwner() {
        let h = Harness(profile: .silent)
        h.mode = "manual"
        h.rpm = 3000
        h.step(40)
        #expect(h.commands.isEmpty)
    }

    @Test("Wake evaluates a reset/new hold after acquiring the hardware lock")
    func latestHoldWins() throws {
        let lock = NSLock()
        var state = DaemonHoldState(command: "set 6000", owner: "app")
        var applied: [String] = []
        // The hold is cleared during the wake delay, before recovery runs.
        state = DaemonHoldState(command: nil, owner: "none")
        WakeRecovery.reapply(lock: lock, snapshot: {
            let unexpectedlyUnlocked = lock.try()
            if unexpectedlyUnlocked { lock.unlock() }
            #expect(!unexpectedlyUnlocked)
            return state
        }, apply: { applied.append($0) })
        #expect(applied.isEmpty)
        // Both a new CLI command and an unchanged hot app hold must survive.
        for owner in ["cli", "app"] {
            state = DaemonHoldState(command: "set 4500", owner: owner)
            WakeRecovery.reapply(lock: lock, snapshot: { state }, apply: { applied.append($0) })
        }
        #expect(applied == ["set 4500", "set 4500"])
    }

    @Test("Wake preserves maximum cooling during safety suspension")
    func suspendedWake() {
        for command: String? in [nil, "set 1500", "max"] {
            let state = DaemonHoldState(command: command, owner: command == nil ? "none" : "app",
                                       safetySuspended: true)
            var applied: String?
            WakeRecovery.reapply(lock: NSLock(), snapshot: { state }, apply: { applied = $0 })
            #expect(applied == "max")
        }
    }

    @Test("Failed wake reapplication propagates its hardware error")
    func failedWake() {
        #expect(throws: (any Error).self) {
            try WakeRecovery.reapply(lock: NSLock(), snapshot: {
                DaemonHoldState(command: "max", owner: "cli")
            }, apply: { _ in throw ThermalForgeError.writeFailed("F0Tg") })
        }
    }
}
