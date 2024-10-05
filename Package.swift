// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Key",
    platforms: [
        .macOS(.v14), // macOS 14 and later
        .iOS(.v17) // iOS 17 and later
    ],
    products: [
        .library(
            name: "Key",
            targets: ["Key"])
    ],
    dependencies: [
        .package(url: "https://github.com/eonist/JSONSugar", branch: "master")
    ],
    targets: [
        .target(
            name: "Key"
        ),
        .testTarget(
            name: "KeyTests",
            dependencies: ["Key", "JSONSugar"])
    ]
)
