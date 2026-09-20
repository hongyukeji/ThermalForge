// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ThermalForgePro",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "ThermalForgeProLocalization",
            resources: [.process("Resources")]
        ),
        .target(
            name: "ThermalForgeProCore",
            path: "Sources/ThermalForgeProCore",
            linkerSettings: [
                .linkedFramework("Metal"),
            ]
        ),
        .executableTarget(
            name: "thermalforgepro",
            dependencies: [
                "ThermalForgeProCore",
                "ThermalForgeProLocalization",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/thermalforgepro"
        ),
        .executableTarget(
            name: "ThermalForgeProApp",
            dependencies: ["ThermalForgeProCore", "ThermalForgeProLocalization"],
            path: "Sources/ThermalForgeProApp"
        ),
        .testTarget(
            name: "ThermalForgeProTests",
            dependencies: ["ThermalForgeProCore", "ThermalForgeProApp", "ThermalForgeProLocalization"],
            path: "Tests/ThermalForgeProTests"
        ),
    ]
)
