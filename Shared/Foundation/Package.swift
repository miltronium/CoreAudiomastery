// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CoreAudioFoundation",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CoreAudioFoundation",
            targets: ["CoreAudioFoundation"]
        ),
        .library(
            name: "CoreAudioFoundationC", 
            targets: ["CoreAudioFoundationC"]
        )
    ],
    dependencies: [
        // Swift Testing for modern test patterns (iOS 18+/macOS 15+)
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.4.0")
    ],
    targets: [
        // C Foundation Target
        .target(
            name: "CoreAudioFoundationC",
            dependencies: [],
            path: "Sources/CoreAudioFoundationC",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .define("CA_FOUNDATION_C"),
                .unsafeFlags(["-framework", "AudioToolbox"]),
                .unsafeFlags(["-framework", "CoreFoundation"])
            ]
        ),
        
        // Swift Foundation Target
        .target(
            name: "CoreAudioFoundation",
            dependencies: ["CoreAudioFoundationC"],
            path: "Sources/CoreAudioFoundation",
            swiftSettings: [
                .define("CA_FOUNDATION_SWIFT")
            ]
        ),
        
        // C Tests Target using Unity
        .testTarget(
            name: "CoreAudioFoundationCTests",
            dependencies: ["CoreAudioFoundationC"],
            path: "Tests/CTests",
            cSettings: [
                .headerSearchPath("../../Sources/CoreAudioFoundationC/include")
            ]
        ),
        
        // Traditional XCTest Target (iOS 12+ compatibility)
        .testTarget(
            name: "CoreAudioFoundationXCTests",
            dependencies: [
                "CoreAudioFoundation",
                "CoreAudioFoundationC"
            ],
            path: "Tests/XCTests"
        ),
        
        // Modern Swift Testing Target (iOS 18+/macOS 15+)
        .testTarget(
            name: "CoreAudioFoundationSwiftTests",
            dependencies: [
                "CoreAudioFoundation",
                "CoreAudioFoundationC",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/SwiftTests"
        )
    ]
)
