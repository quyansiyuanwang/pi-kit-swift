// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PiKit",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "PiKit", targets: ["PiKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/quyansiyuanwang/pi-ai-swift.git", exact: "0.1.2"),
        .package(url: "https://github.com/quyansiyuanwang/pi-agent-swift.git", exact: "0.1.2")
    ],
    targets: [
        .target(
            name: "PiKit",
            dependencies: [
                .product(name: "PiAI", package: "pi-ai-swift"),
                .product(name: "PiAgentCore", package: "pi-agent-swift")
            ],
            path: "Sources/PiKit"
        ),
        .testTarget(
            name: "PiKitTests",
            dependencies: ["PiKit"],
            path: "Tests/PiKitTests"
        )
    ]
)
