// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "Core",
            type: .dynamic,
            targets: ["Core"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxAlamofire", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [.product(name: "ObjectMapper", package: "ObjectMapper"),
                           .product(name: "RxSwift", package: "RxSwift"),
                           .product(name: "RxCocoa", package: "RxSwift"),
                           .product(name: "RxAlamofire", package: "RxAlamofire"),
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
    ]
)
