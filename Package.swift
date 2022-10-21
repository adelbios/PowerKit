// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PowerKit",
    platforms: [
        .iOS(.v14),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "PowerKit",
            targets: ["PowerKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/Juanpe/SkeletonView.git", .upToNextMajor(from: "1.30.4")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "PowerKit",
            dependencies: ["Moya", "JGProgressHUD", "SkeletonView", "SnapKit"]
        ),
        .testTarget(
            name: "PowerKitTests",
            dependencies: ["PowerKit"]),
    ]
)
