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
        .library(
            name: "CombineErgonomics",
            targets: ["CombineErgonomics"]
        ),
        .library(
            name: "CombineErgonomicsTestExtensions",
            targets: ["CombineErgonomicsTestExtensions"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CombineErgonomics",
            dependencies: [],
            path: "Sources",
            exclude: ["XCTestExtensions.swift"]
        ),
        .target(
            name: "CombineErgonomicsTestExtensions",
            dependencies: [],
            path: "Sources",
            // Excludes are enumerated manually here to stifle an Xcode workspace warning.
            exclude: [
                "CancellableStoring.swift",
                "PromiseFinalizer.swift",
                "SingleValueSubscriber.swift",
                "PublisherExtensions.swift"
            ]
        ),
        .testTarget(
            name: "CombineErgonomicsTests",
            dependencies: ["CombineErgonomics", "CombineErgonomicsTestExtensions"],
            path: "Tests"
        )
    ]
)
