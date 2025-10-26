// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Gym",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "GymCore", targets: ["GymCore"]),
        .executable(name: "gym", targets: ["GymApp"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GymCore",
            path: "Sources/GymCore"
        ),
        .executableTarget(
            name: "GymApp",
            dependencies: ["GymCore"],
            path: "Sources/GymApp"
        ),
        .testTarget(
            name: "GymCoreTests",
            dependencies: ["GymCore"],
            path: "Tests/GymCoreTests"
        )
    ]
)
