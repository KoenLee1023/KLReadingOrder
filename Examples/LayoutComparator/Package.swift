// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LayoutComparator",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "LayoutComparator",
            dependencies: [.product(name: "KLReadingOrder", package: "KLReadingOrder")]
        ),
    ]
)
