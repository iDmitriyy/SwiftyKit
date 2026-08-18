//
 //  Bundle+AppVersion.swift
 //  SwiftyKit
 //
 //  Created by Dmitriy Ignatyev on 13.12.2024.
 //

import StdLibExtensions
@_spiOnly @_spi(SwiftyKitBuiltinTypes) private import struct IndependentDeclarations.TextError

extension Bundle {
  public enum Key {
    public static let appVersion = "CFBundleShortVersionString"
    public static let appBuildNumber = "CFBundleVersion"
  }
  
  public static let mainAppVersionString: String = (Bundle.main.infoDictionary?[Key.appVersion] as? String) ?? "0"
  
  public static let mainAppBuildNumberString: String = (Bundle.main.infoDictionary?[Key.appBuildNumber] as? String) ?? "0"
  
  public static var mainAppFullVersionString: String { String(describing: mainAppVersion) + " (\(mainAppBuildNumberString))" }

  public static let mainAppVersion: SemVerAppVersion = .compileTimeDefined
  public static let mainAppBuildNumber = Int(mainAppBuildNumberString)!
}

public struct SemVerAppVersion: Sendable, LosslessStringConvertible {
  public let preRelease: [String]
  public let buildMetadata: [String]
  public let major: UInt16
  public let minor: UInt16
  public let patch: UInt16
  
  public var description: String {
    var result = "\(major).\(minor).\(patch)"
    if !preRelease.isEmpty {
      result += "-" + preRelease.joined(separator: ".")
    }
    if !buildMetadata.isEmpty {
      result += "+" + buildMetadata.joined(separator: ".")
    }
    return result
  }
  
  public init(major: UInt16, minor: UInt16, patch: UInt16, preRelease: [String] = [], buildMetadata: [String] = []) {
    self.preRelease = preRelease
    self.buildMetadata = buildMetadata
    self.major = major
    self.minor = minor
    self.patch = patch
  }
  
  public init(description: String) throws {
    let parsed = try SemVerAppVersion.parse(description)
    self = parsed
  }
  
  public init?(_ description: String) {
    try? self.init(description: description)
  }
  
  private static func parse(_ versionString: String) throws -> SemVerAppVersion {
    var remaining = versionString
    var buildMetadata: [String] = []
    
    if let plusIndex = remaining.firstIndex(of: "+") {
      let buildPart = remaining[remaining.index(after: plusIndex)...]
      buildMetadata = buildPart.split(separator: ".").map(String.init)
      try validateIdentifiers(buildMetadata, context: "build metadata")
      remaining = String(remaining[..<plusIndex])
    }
    
    var preRelease: [String] = []
    if let dashIndex = remaining.firstIndex(of: "-") {
      let prePart = remaining[remaining.index(after: dashIndex)...]
      preRelease = prePart.split(separator: ".").map(String.init)
      try validateIdentifiers(preRelease, context: "pre-release")
      remaining = String(remaining[..<dashIndex])
    }
    
    let coreComponents = remaining.split(separator: ".").map(String.init)
    guard coreComponents.count == 3 else {
      throw TextError(text: "Invalid version core: expected 3 components, got \(coreComponents.count) in \(versionString)")
    }
    
    let major = try parseUInt16(coreComponents[0], name: "major")
    let minor = try parseUInt16(coreComponents[1], name: "minor")
    let patch = try parseUInt16(coreComponents[2], name: "patch")
    
    return SemVerAppVersion(major: major, minor: minor, patch: patch, preRelease: preRelease, buildMetadata: buildMetadata)
  }
  
  private static func parseUInt16(_ string: String, name: String) throws -> UInt16 {
    guard !string.isEmpty else { throw TextError(text: "Empty \(name) component") }
    guard string.allSatisfy(\.isNumber) else { throw TextError(text: "Non-numeric \(name) component: \(string)") }
    guard !string.hasPrefix("0") || string == "0" else { throw TextError(text: "Leading zeros in \(name) component: \(string)") }
    guard let value = UInt16(string) else { throw TextError(text: "\(name) component out of range: \(string)") }
    return value
  }
  
  private static func validateIdentifiers(_ identifiers: [String], context: String) throws {
    for identifier in identifiers {
      guard !identifier.isEmpty else { throw TextError(text: "Empty identifier in \(context)") }
      guard identifier.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" }) else {
        throw TextError(text: "Invalid character in \(context) identifier: \(identifier)")
      }
      if identifier.allSatisfy(\.isNumber), identifier.count > 1, identifier.hasPrefix("0") {
        throw TextError(text: "Leading zeros in numeric \(context) identifier: \(identifier)")
      }
    }
  }
}

extension SemVerAppVersion: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.major == rhs.major &&
    lhs.minor == rhs.minor &&
    lhs.patch == rhs.patch &&
    lhs.preRelease == rhs.preRelease
  }
}

extension SemVerAppVersion: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.major != rhs.major { return lhs.major < rhs.major }
    if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
    if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
    
    let lhsIsRelease = lhs.preRelease.isEmpty
    let rhsIsRelease = rhs.preRelease.isEmpty
    
    if lhsIsRelease != rhsIsRelease {
      return !lhsIsRelease
    }
    
    if lhsIsRelease { return false }
    
    return comparePreRelease(lhs.preRelease, rhs.preRelease)
  }
  
  private static func comparePreRelease(_ lhs: [String], _ rhs: [String]) -> Bool {
    let count = min(lhs.count, rhs.count)
    for i in 0..<count {
      let l = lhs[i]
      let r = rhs[i]
      let lNumeric = l.allSatisfy(\.isNumber)
      let rNumeric = r.allSatisfy(\.isNumber)
      
      if lNumeric && rNumeric {
        let lv = Int(l) ?? 0
        let rv = Int(r) ?? 0
        if lv != rv { return lv < rv }
      } else if lNumeric != rNumeric {
        return lNumeric
      } else {
        if l != r { return l < r }
      }
    }
    return lhs.count < rhs.count
  }
}

extension SemVerAppVersion: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self = try SemVerAppVersion.parse(string)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }
}

extension SemVerAppVersion {
  fileprivate static let compileTimeDefined: SemVerAppVersion = {
    (try? parse(Bundle.mainAppVersionString)) ?? SemVerAppVersion(major: 0, minor: 0, patch: 0)
  }()
}