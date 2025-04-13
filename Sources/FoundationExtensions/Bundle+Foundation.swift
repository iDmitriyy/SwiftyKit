//
//  Bundle+Foundation.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

// swiftlint:disable force_unwrapping
extension Bundle {
  public var bundleId: String { bundleIdentifier! }
  
  public var bundleName: String { bundleId.components(separatedBy: ".").last ?? "" }
  
  /// Example: "com.myCompany"
  public static let mainBundleOrganizationId: String = organizationId(ofBundle: Bundle.main)
  
  /// Example: "com.myCompany"
  public static func organizationId(ofBundle bundle: Bundle) -> String {
    let components = bundle.bundleId.components(separatedBy: ".").prefix(2)
    return components.joined(separator: ".")
  }
} // swiftlint:enable force_unwrapping
