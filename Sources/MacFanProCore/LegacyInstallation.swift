import Foundation

/// Previous products have distinct services and data. Keep their identities
/// explicit so a rename cannot leave a second fan controller running.
public enum LegacyInstallation: CaseIterable, Sendable {
    case thermalForge
    case thermalForgePro

    public var name: String { self == .thermalForge ? "ThermalForge" : "ThermalForgePro" }
    public var command: String { name.lowercased() }
    public var executableName: String { "\(name)App" }
    public var appPath: String { "/Applications/\(name).app" }
    public var binaryPath: String { "/usr/local/bin/\(command)" }
    public var bundleIdentifier: String {
        self == .thermalForge ? "com.thermalforge.app" : "io.github.hongyukeji.thermalforgepro.app"
    }
    public var daemonLabel: String {
        self == .thermalForge ? "com.thermalforge.daemon" : "io.github.hongyukeji.thermalforgepro.daemon"
    }
    public var plistPath: String { "/Library/LaunchDaemons/\(daemonLabel).plist" }
    public var socketPath: String { "/var/run/\(command).sock" }

    public static func select(from present: [Self], requested: Self?) throws -> Self? {
        guard present.count <= 1 else { throw MigrationError.multipleInstallations }
        guard let legacy = present.first else { return nil }
        guard requested == legacy else { throw MigrationError.authorizationRequired(legacy) }
        return legacy
    }

    public enum MigrationError: LocalizedError {
        case multipleInstallations
        case authorizationRequired(LegacyInstallation)

        public var errorDescription: String? {
            switch self {
            case .multipleInstallations:
                return "Both ThermalForge and ThermalForgePro are installed. Remove one before migrating so only one fan controller is replaced."
            case .authorizationRequired(let legacy):
                return "\(legacy.name) is installed. To replace it, run: sudo macfanpro install --migrate-\(legacy.command)"
            }
        }
    }
}
