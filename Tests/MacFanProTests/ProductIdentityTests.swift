import Testing
@testable import MacFanProCore
import MacFanProLocalization

@Suite("Independent product and migration boundaries")
struct ProductIdentityTests {
    @Test("Migration requires the matching legacy product and rejects competing controllers")
    func migrationSelection() throws {
        for legacy in LegacyInstallation.allCases {
            #expect(try LegacyInstallation.select(from: [legacy], requested: legacy) == legacy)
            #expect(throws: LegacyInstallation.MigrationError.self) {
                try LegacyInstallation.select(from: [legacy], requested: nil)
            }
            let other: LegacyInstallation = legacy == .thermalForge ? .thermalForgePro : .thermalForge
            #expect(throws: LegacyInstallation.MigrationError.self) {
                try LegacyInstallation.select(from: [legacy], requested: other)
            }
        }
        #expect(try LegacyInstallation.select(from: [], requested: nil) == nil)
        #expect(throws: LegacyInstallation.MigrationError.self) {
            try LegacyInstallation.select(from: LegacyInstallation.allCases, requested: .thermalForgePro)
        }
        #expect(LegacyInstallation.thermalForgePro.bundleIdentifier == "io.github.hongyukeji.thermalforgepro.app")
        #expect(LegacyInstallation.thermalForgePro.plistPath == "/Library/LaunchDaemons/io.github.hongyukeji.thermalforgepro.daemon.plist")
        #expect(LegacyInstallation.thermalForge.socketPath == "/var/run/thermalforge.sock")
    }

    @Test("Updates, IPC and resources use only the Pro identity")
    func independentIdentity() {
        #expect(UpdateChecker.releasesAPIURL.absoluteString == "https://api.github.com/repos/macfanpro/macfanpro/releases/latest")
        #expect(UpdateChecker.releasesPageURL == "https://github.com/macfanpro/macfanpro/releases/latest")
        #expect(MacFanProDaemon.socketPath == "/var/run/macfanpro.sock")
        #expect(MacFanProDaemon.label == "io.github.macfanpro.daemon")
        #expect(MacFanProDaemon.installPath == "/usr/local/bin/macfanpro")
        #expect(LocalizationCatalog.resourceBundleName == "MacFanPro_MacFanProLocalization.bundle")
    }

    @Test("Migration preserves choices without carrying the upstream update cache")
    func migratePreferences() {
        let old: [String: Any] = ["guiLanguage": "zh-Hant", "useFahrenheit": true,
                                  "selectedProfile": "smart", "updateLatestURL": "https://example.com/old",
                                  "updateLatestVersion": "99.0.0", "updateDismissedVersion": "99.0.0"]
        let result = LegacyPreferences.merging(old: old, current: [:])
        #expect(result.count == 3)
        #expect(result["guiLanguage"] as? String == "zh-Hant")
        #expect(result["useFahrenheit"] as? Bool == true)
        #expect(result["selectedProfile"] as? String == "smart")
        #expect(old.count == 6)
    }

    @Test("Existing Pro preferences win over legacy choices")
    func keepCurrentPreferences() {
        let result = LegacyPreferences.merging(old: ["guiLanguage": "zh-Hant", "selectedProfile": "smart"],
                                              current: ["guiLanguage": "en", "selectedProfile": "balanced", "extra": "keep"])
        #expect(result["guiLanguage"] as? String == "en")
        #expect(result["selectedProfile"] as? String == "balanced")
        #expect(result["extra"] as? String == "keep")
    }
}
