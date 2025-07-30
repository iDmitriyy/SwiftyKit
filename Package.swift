// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swifty-kit",
  platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "SwiftyKit", targets: ["SwiftyKit"]),
    
    .library(name: "StdLibExtensions", targets: ["StdLibExtensions"]),
    .library(name: "FoundationExtensions", targets: ["FoundationExtensions"]),
    .library(name: "FunctionalTypes", targets: ["FunctionalTypes"]),
    .library(name: "ErrorInfo", targets: ["ErrorInfo"]),
    .library(name: "SwiftyKitMacros", targets: ["Macros"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.2.1")),
    .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.2.1")),
    .package(url: "https://github.com/pointfreeco/swift-nonempty.git", .upToNextMajor(from: "0.5.0")),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "601.0.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "SwiftyKit", dependencies: [.target(name: "IndependentDeclarations"),
                                              .target(name: "StdLibExtensions"),
                                              .target(name: "FoundationExtensions"),
                                              .target(name: "ErrorInfo"),
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
    .target(name: "ErrorInfo", dependencies: [.target(name: "IndependentDeclarations"),
                                              .target(name: "StdLibExtensions"),
                                              .target(name: "FoundationExtensions"),
                                              .target(name: "CrossImportOverlays")]),
    .target(name: "CrossImportOverlays", dependencies: [.target(name: "IndependentDeclarations"),
                                                        .product(name: "Collections", package: "swift-collections")]),
            
      .target(name: "Macros",
              dependencies: ["MacroImps"],
              path: "Sources/Macros/Declarations"),
    
      .macro(name: "MacroImps",
             dependencies: [.target(name: "IndependentDeclarations"),
                            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")],
             path: "Sources/Macros/MacroImps"),
    // MARK: - Test Targets
    
    .testTarget(name: "SwiftyKitTests", dependencies: [.target(name: "SwiftyKit")]),
    .testTarget(name: "IndependentDeclarationsTests", dependencies: ["IndependentDeclarations"]),
    .testTarget(name: "StdLibExtensionsTests", dependencies: ["StdLibExtensions"]),
    .testTarget(name: "ErrorInfoTests", dependencies: ["ErrorInfo"]),
    .testTarget(name: "FoundationExtensionsTests", dependencies: ["FoundationExtensions",
                                                                  .product(name: "NonEmpty", package: "swift-nonempty")]),
//    .testTarget(name: "MacrosTests", dependencies: [.target(name: "MacroImps"),
//                                                    .target(name: "IndependentDeclarations"),
//                                                    .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")]),
  ],
  swiftLanguageModes: [.v6]
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
