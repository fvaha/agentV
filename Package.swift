// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UniversalAgent",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "UniversalAgent",
            targets: ["UniversalAgent"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.7")
    ],
    targets: [
        .target(
            name: "UniversalAgent",
            dependencies: [
                .product(name: "AnyCodable", package: "AnyCodable")
            ],
            path: "Sources/UniversalAgent"
        ),
        .testTarget(
            name: "UniversalAgentTests",
            dependencies: ["UniversalAgent"],
            path: "TEST/UniversalAgentTests"
        )
    ]
)

