// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swifty-kit",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "SwiftyKit", targets: ["SwiftyKit"]),
    
    .library(name: "StdLibExtensions", targets: ["StdLibExtensions"]),
    .library(name: "FoundationExtensions", targets: ["FoundationExtensions"]),
    .library(name: "FunctionalTypes", targets: ["FunctionalTypes"]),
    .library(name: "ErrorInfo", targets: ["ErrorInfo"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.2.1")),
    .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.2.1")),
    .package(url: "https://github.com/pointfreeco/swift-nonempty.git", .upToNextMajor(from: "0.5.0")),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "SwiftyKit", dependencies: [.target(name: "IndependentDeclarations"),
                                              .target(name: "StdLibExtensions"),
                                              .target(name: "FoundationExtensions"),
                                              .target(name: "ErrorInfo"),
                                              .product(name: "Collections", package: "swift-collections"),
                                              .product(name: "Algorithms", package: "swift-algorithms"),
                                              .product(name: "NonEmpty", package: "swift-nonempty")]),
    .target(name: "FunctionalTypes", dependencies: [.target(name: "IndependentDeclarations")]),
    .target(name: "IndependentDeclarations"),
    .target(name: "StdLibExtensions", dependencies: [.target(name: "IndependentDeclarations")]),
    .target(name: "FoundationExtensions", dependencies: [.target(name: "IndependentDeclarations"),
                                                         .target(name: "StdLibExtensions"),
                                                         .product(name: "NonEmpty", package: "swift-nonempty")]),
    .target(name: "ErrorInfo", dependencies: [.target(name: "IndependentDeclarations"),
                                              .target(name: "StdLibExtensions"),
                                              .target(name: "FoundationExtensions"),
                                              .target(name: "CrossImportOverlays")]),
    .target(name: "CrossImportOverlays", dependencies: [.target(name: "IndependentDeclarations"),
                                                        .product(name: "Collections", package: "swift-collections")]),
    
    // MARK: - Test Targets
    
    .testTarget(name: "SwiftyKitTests", dependencies: [.target(name: "SwiftyKit")]),
    .testTarget(name: "IndependentDeclarationsTests", dependencies: ["IndependentDeclarations"]),
    .testTarget(name: "StdLibExtensionsTests", dependencies: ["StdLibExtensions"]),
    .testTarget(name: "FoundationExtensionsTests", dependencies: ["FoundationExtensions",
                                                                  .product(name: "NonEmpty", package: "swift-nonempty")]),
  ]
)

for target: PackageDescription.Target in package.targets {
  {
    var settings: [PackageDescription.SwiftSetting] = $0 ?? []
    settings.append(.enableUpcomingFeature("ExistentialAny"))
    settings.append(.enableUpcomingFeature("InternalImportsByDefault"))
    settings.append(.enableUpcomingFeature("MemberImportVisibility"))
    $0 = settings
  }(&target.swiftSettings)
}
