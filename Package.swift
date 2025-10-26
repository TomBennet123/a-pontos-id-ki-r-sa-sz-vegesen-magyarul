// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Gym",
    defaultLocalization: "hu",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "GymDomain", targets: ["Domain"]),
        .library(name: "GymPersistence", targets: ["Persistence"]),
        .library(name: "GymHealth", targets: ["Health"]),
        .library(name: "GymAI", targets: ["AICore"]),
        .executable(name: "GymApp", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.26.0")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain"
        ),
        .target(
            name: "Persistence",
            dependencies: [
                "Domain",
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources/Persistence",
            resources: [
                .process("Migrations")
            ]
        ),
        .target(
            name: "Health",
            dependencies: [
                "Domain"
            ],
            path: "Sources/Health"
        ),
        .target(
            name: "AICore",
            dependencies: [
                "Domain"
            ],
            path: "Sources/AI"
        ),
        .target(
            name: "AppIntents",
            dependencies: ["Domain", "Persistence", "AICore"],
            path: "Sources/AppIntents"
        ),
        .target(
            name: "WatchApp",
            dependencies: ["Domain", "Persistence", "Health"],
            path: "Sources/WatchApp"
        ),
        .executableTarget(
            name: "App",
            dependencies: ["Domain", "Persistence", "Health", "AICore", "AppIntents"],
            path: "Sources/App"
        ),
        .testTarget(
            name: "GymTests",
            dependencies: ["Domain", "Persistence", "AICore"],
            path: "Tests/GymTests"
        )
    ]
)
