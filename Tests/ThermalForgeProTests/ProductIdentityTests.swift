import Testing
@testable import ThermalForgeProCore
import ThermalForgeProLocalization

@Suite("Independent product and migration boundaries")
struct ProductIdentityTests {
    @Test("Updates, IPC and resources use only the Pro identity")
    func independentIdentity() {
        #expect(UpdateChecker.releasesAPIURL.absoluteString == "https://api.github.com/repos/hongyukeji/ThermalForgePro/releases/latest")
        #expect(UpdateChecker.releasesPageURL == "https://github.com/hongyukeji/ThermalForgePro/releases/latest")
        #expect(ThermalForgeProDaemon.socketPath == "/var/run/thermalforgepro.sock")
        #expect(ThermalForgeProDaemon.label == "io.github.hongyukeji.thermalforgepro.daemon")
        #expect(ThermalForgeProDaemon.installPath == "/usr/local/bin/thermalforgepro")
        #expect(LocalizationCatalog.resourceBundleName == "ThermalForgePro_ThermalForgeProLocalization.bundle")
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
