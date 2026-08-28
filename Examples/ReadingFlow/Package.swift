// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ReadingFlow",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "ReadingFlow",
            dependencies: [.product(name: "KLReadingOrder", package: "KLReadingOrder")]
        ),
    ]
)
