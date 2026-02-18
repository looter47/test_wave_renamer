// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WaveRenamer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WaveRenamer", targets: ["WaveRenamer"])
    ],
    targets: [
        .executableTarget(
            name: "WaveRenamer",
            path: "Sources/WaveRenamer"
        )
    ]
)
