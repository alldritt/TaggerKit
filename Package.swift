// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TaggerKit",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "TaggerKit", targets: ["TaggerKit"])
    ],
    targets: [
        .target(
            name: "TaggerKit",
            path: "TaggerKit"
        )
    ]
)
