// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swifty-kit",
  // (macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
  platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .macCatalyst(.v18), .watchOS(.v11), .visionOS(.v2)],
  products: [
    .library(name: "SwiftyKit", targets: ["SwiftyKit"]),
    
    .library(name: "StdLibExtensions", targets: ["StdLibExtensions"]),
    .library(name: "FoundationExtensions", targets: ["FoundationExtensions"]),
    .library(name: "FunctionalTypes", targets: ["FunctionalTypes"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "SwiftyKit", dependencies: [.target(name: "IndependentDeclarations"),
                                              .target(name: "StdLibExtensions"),
                                              .target(name: "FoundationExtensions")]),
    .target(name: "FunctionalTypes", dependencies: [.target(name: "IndependentDeclarations")]),
    .target(name: "IndependentDeclarations"),
    .target(name: "StdLibExtensions", dependencies: [.target(name: "IndependentDeclarations")]),
    .target(name: "FoundationExtensions", dependencies: [.target(name: "IndependentDeclarations"),
                                                         .target(name: "StdLibExtensions")]),
    
    // MARK: - Test Targets
    
    .testTarget(name: "SwiftyKitTests", dependencies: [.target(name: "SwiftyKit")]),
    .testTarget(name: "IndependentDeclarationsTests", dependencies: ["IndependentDeclarations"]),
    .testTarget(name: "StdLibExtensionsTests", dependencies: ["StdLibExtensions"]),
    .testTarget(name: "FoundationExtensionsTests", dependencies: ["FoundationExtensions"]),
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
