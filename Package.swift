// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CombineErgonomics",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CombineErgonomics",
            targets: ["CombineErgonomics"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CombineErgonomics",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CombineErgonomicsTests",
            dependencies: ["CombineErgonomics"],
            path: "Tests"
        )
    ]
)
