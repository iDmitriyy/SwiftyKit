//
//  Bundle+AppVersion.swift
//  SwiftyKit
//
//  Created by Dmitriy Ignatyev on 13.12.2024.
//

import StdLibExtensions
@_spiOnly @_spi(SwiftyKitBuiltinTypes) private import struct IndependentDeclarations.TextError

// swiftlint:disable force_unwrapping
extension Bundle {
  public enum Key { // :Namespacing TODO: - compiler error in another package when StdLibExtensions imported with internal ACL
    public static let appVersion = "CFBundleShortVersionString"
    public static let appBuildNumber = "CFBundleVersion"
  }
  
  public static let mainAppVersionString: String = (Bundle.main.infoDictionary?[Key.appVersion] as? String) ?? "0"
  
  public static let mainAppBuildNumberString: String = (Bundle.main.infoDictionary?[Key.appBuildNumber] as? String) ?? "0"
  
  public static var mainAppFullVersionString: String { String(describing: mainAppVersion) + " (\(mainAppBuildNumberString))" }

  public static let mainAppVersion: SemVerAppVersion = .compileTimeDefined
  public static let mainAppBuildNumber = Int(mainAppBuildNumberString)!
}

public struct SemVerAppVersion: Sendable, LosslessStringConvertible, BitwiseCopyable {
  public let major: UInt16
  public let minor: UInt16
  public let patch: UInt16

  public var description: String { components.map { String($0) }.joined(separator: ".") }

  private var components: ContiguousArray<UInt16> { [major, minor, patch] }

  public init(major: UInt16, minor: UInt16, patch: UInt16) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }

  public init(description: String) throws {
    let components = SemVerAppVersion.appVersionComponents(description)
    self = try SemVerAppVersion.fromComponents(components: components)
  }
  
  public init?(_ description: String) {
    try? self.init(description: description)
  }

  private static func fromComponents(components: [UInt16]) throws -> Self {
    func error(component name: String) -> any Error {
      TextError(text: "Missing AppVersion component \(name) in \(components)")
    }
    
    guard let major = components[at: 0] else { throw error(component: "major") }
    guard let minor = components[at: 1] else { throw error(component: "minor") }
    guard let patch = components[at: 2] else { throw error(component: "patch") }
    // TODO: - assert components.count > 3
    return Self(major: major, minor: minor, patch: patch)
  }
  
  private static func appVersionComponents(_ versionString: String) -> [UInt16] {
    let separator: String = "."
    let charset = CharacterSet.arabicNumerals.union(CharacterSet(charactersIn: separator))
    let versionString = versionString.removingCharacters(except: charset)

    let components = versionString.split(separator: ".")
    let numberComponents: [UInt16] = components.map { UInt16($0)! }
    
    return numberComponents
  }
}

// swiftlint:enable force_unwrapping

extension SemVerAppVersion: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    let isLess = (lhs.major < rhs.major) ||
      (lhs.major == rhs.major && lhs.minor < rhs.minor) ||
      (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    return isLess
  }
}

extension SemVerAppVersion: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()

    let components: [UInt16] = try container.decode([UInt16].self)
    self = try SemVerAppVersion.fromComponents(components: components)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(components)
  }
}

extension SemVerAppVersion {
  fileprivate static let compileTimeDefined: SemVerAppVersion = {
    let components = appVersionComponents(Bundle.mainAppVersionString)
    return (try? fromComponents(components: components)) ?? SemVerAppVersion(major: 0, minor: 0, patch: 0)
  }()
}
