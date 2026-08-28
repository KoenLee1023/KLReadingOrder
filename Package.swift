// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "KLReadingOrder",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "KLReadingOrder", targets: ["KLReadingOrder"])],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.4.0"
        ),
    ],
    targets: [
        .target(name: "KLReadingOrder"),
        .testTarget(name: "KLReadingOrderTests", dependencies: ["KLReadingOrder"]),
    ]
)
