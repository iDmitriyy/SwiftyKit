// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swifty-kit",
  // (macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
  platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .macCatalyst(.v18), .watchOS(.v11), .visionOS(.v2)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "SwiftyKit", targets: ["SwiftyKit"]),
    
    .library(name: "StdLibExtensions", targets: ["StdLibExtensions"]),
    .library(name: "FoundationExtensions", targets: ["FoundationExtensions"]),
    .library(name: "FunctionalTypes", targets: ["FunctionalTypes"]),
//    .library(name: "ErrorInfo", targets: ["ErrorInfo"]),
    .library(name: "SwiftyKitMacros", targets: ["Macros"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.2.1")),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.2.1")),
    //    .package(url: "https://github.com/pointfreeco/swift-nonempty.git", .upToNextMajor(from: "0.5.0")),
    .package(url: "https://github.com/iDmitriyy/swift-nonempty.git", branch: "SwiftCollectionsAdditions"), // "0.5.0"
    .package(url: "https://github.com/iDmitriyy/SwiftCollections-NonEmpty.git", branch: "main"),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "601.0.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "SwiftyKit", dependencies: [.target(name: "IndependentDeclarations"),
                                              .target(name: "StdLibExtensions"),
                                              .target(name: "FoundationExtensions"),
//                                              .target(name: "ErrorInfo"),
                                              .target(name: "Macros"),
                                              .product(name: "Collections", package: "swift-collections"),
                                              .product(name: "Algorithms", package: "swift-algorithms"),
                                              .product(name: "NonEmpty", package: "swift-nonempty")]),
    .target(name: "FunctionalTypes", dependencies: [.target(name: "IndependentDeclarations")]),
    .target(name: "IndependentDeclarations"),
    .target(name: "StdLibExtensions", dependencies: [.target(name: "IndependentDeclarations")]),
    .target(name: "FoundationExtensions", dependencies: [.target(name: "IndependentDeclarations"),
                                                         .target(name: "StdLibExtensions"),
                                                         .product(name: "NonEmpty", package: "swift-nonempty")]),
//    .target(name: "ErrorInfo", dependencies: [.target(name: "IndependentDeclarations"),
//                                              .target(name: "StdLibExtensions"),
//                                              .target(name: "FoundationExtensions"),
//                                              .target(name: "CrossImportOverlays")]),
    .target(name: "CrossImportOverlays", dependencies: [.target(name: "IndependentDeclarations"),
                                                        .product(name: "Collections", package: "swift-collections")]),
            
    .target(name: "Macros",
            dependencies: [.target(name: "MacroImps"),
                           .target(name: "MacroSymbols")],
            path: "Sources/Macros/Declarations"),
    
    .macro(name: "MacroImps",
           dependencies: [.target(name: "MacroSymbols"),
                          .target(name: "IndependentDeclarations"),
                          .target(name: "StdLibExtensions"),
                          .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                          .product(name: "SwiftCompilerPlugin", package: "swift-syntax")],
           path: "Sources/Macros/MacroImps"),
    .target(name: "MacroSymbols",
            dependencies: [],
            path: "Sources/Macros/MacroSymbols"),
    
    // MARK: - Test Targets
    
    .testTarget(name: "SwiftyKitTests", dependencies: [.target(name: "SwiftyKit")]),
    .testTarget(name: "IndependentDeclarationsTests", dependencies: ["IndependentDeclarations"]),
    .testTarget(name: "StdLibExtensionsTests", dependencies: ["StdLibExtensions"]),
//    .testTarget(name: "ErrorInfoTests", dependencies: ["ErrorInfo"]),
    .testTarget(name: "FoundationExtensionsTests", dependencies: ["FoundationExtensions",
                                                                  .product(name: "NonEmpty", package: "swift-nonempty")]),
    .testTarget(name: "MacrosTests", dependencies: [.target(name: "MacroImps"),
                                                    .target(name: "MacroSymbols"),
                                                    .target(name: "IndependentDeclarations"),
                                                    .target(name: "StdLibExtensions"),
                                                    .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")]),
  ],
  swiftLanguageModes: [.v6],
)

for target: PackageDescription.Target in package.targets {
  {
    var settings: [PackageDescription.SwiftSetting] = $0 ?? []
    settings.append(.enableUpcomingFeature("ExistentialAny"))
    settings.append(.enableUpcomingFeature("InternalImportsByDefault"))
    settings.append(.enableUpcomingFeature("MemberImportVisibility"))
    settings.append(.enableExperimentalFeature("BorrowingSwitch"))
    settings.append(.enableExperimentalFeature("NoImplicitCopy"))
    settings.append(.enableExperimentalFeature("LifetimeDependence"))
    settings.append(.enableExperimentalFeature("Lifetimes"))
//    settings.append(.enableExperimentalFeature("DoExpressions"))
    
    $0 = settings
  }(&target.swiftSettings)
}
