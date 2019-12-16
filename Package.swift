// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Trampoline",
    products: [
        .library(
            name: "Trampoline",
            targets: ["Trampoline"]
        )
    ],
    targets: [
        .target(name: "Trampoline"),
        .testTarget(
            name: "TrampolineTests",
            dependencies: ["Trampoline"]
        )
    ]
)

