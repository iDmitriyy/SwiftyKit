//
//  SemVer.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 01.10.2026.
//

/// Semantic Versioning 2.0.0 implementation.
/// See https://semver.org/spec/v2.0.0.html
public struct SemVer: Sendable, LosslessStringConvertible {
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
  
  public init(major: UInt16, minor: UInt16, patch: UInt16, preRelease: [String], buildMetadata: [String]) throws {
    if !preRelease.isEmpty { try Self.validateIdentifiers(preRelease, context: .preRelease) }
    if !buildMetadata.isEmpty { try Self.validateIdentifiers(buildMetadata, context: .buildMetadata) }
    
    self.preRelease = preRelease
    self.buildMetadata = buildMetadata
    self.major = major
    self.minor = minor
    self.patch = patch
  }
  
  public init(major: UInt16, minor: UInt16, patch: UInt16) {
    self.preRelease = []
    self.buildMetadata = []
    self.major = major
    self.minor = minor
    self.patch = patch
  }
  
  public init(description: String) throws {
    self = try SemVer.parse(description)
  }
  
  public init?(_ description: String) {
    try? self.init(description: description)
  }
  
  private static func parse(_ versionString: String) throws -> SemVer {
    var remaining = versionString
    var buildMetadata: [String] = []
    
    if let plusIndex = remaining.firstIndex(of: "+") {
      let buildPart = remaining[remaining.index(after: plusIndex)...]
      buildMetadata = buildPart.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
      try validateIdentifiers(buildMetadata, context: .buildMetadata)
      remaining = String(remaining[..<plusIndex])
    }
    
    var preRelease: [String] = []
    if let dashIndex = remaining.firstIndex(of: "-") {
      let prePart = remaining[remaining.index(after: dashIndex)...]
      preRelease = prePart.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
      try validateIdentifiers(preRelease, context: .preRelease)
      remaining = String(remaining[..<dashIndex])
    }
    
    let coreComponents = remaining.split(separator: ".", omittingEmptySubsequences: false)
    guard coreComponents.count == 3 else {
      throw TextError(text: "Invalid version core: expected 3 components, got \(coreComponents.count) in \(versionString)")
    }
    
    let major = try parseUInt16(coreComponents[0], componentName: "major")
    let minor = try parseUInt16(coreComponents[1], componentName: "minor")
    let patch = try parseUInt16(coreComponents[2], componentName: "patch")
    
    return try SemVer(major: major, minor: minor, patch: patch, preRelease: preRelease, buildMetadata: buildMetadata)
  }
  
  private static func isASCIINumber(_ character: Character) -> Bool {
    character.isASCII && character.isNumber
  }
  
  private static func isASCIILetter(_ character: Character) -> Bool {
    character.isASCII && character.isLetter
  }
  
  private static func isASCIIAlphanumericOrHyphen(_ character: Character) -> Bool {
    character.isASCII && (character.isLetter || character.isNumber || character == "-")
  }
  
  private static func parseUInt16(_ string: some StringProtocol, componentName name: String) throws -> UInt16 {
    guard !string.isEmpty else { throw TextError(text: "Empty \(name) component") }
    guard string.allSatisfy(isASCIINumber) else { throw TextError(text: "Non-ASCII numeric \(name) component: \(string)") }
    guard string.count == 1 || !string.hasPrefix("0") else {
      throw TextError(text: "Leading zeros in \(name) component: \(string)")
    }
    guard let value = UInt16(string) else { throw TextError(text: "\(name) component out of range: \(string)") }
    return value
  }
  
  private static func validateIdentifiers(_ identifiers: [String], context: IdentifiersKind) throws {
    for identifier in identifiers {
      guard !identifier.isEmpty else { throw TextError(text: "Empty identifier in \(context)") }
      guard identifier.allSatisfy(isASCIIAlphanumericOrHyphen) else {
        throw TextError(text: "Invalid character in \(context) identifier: \(identifier)")
      }
      // Leading zeros only forbidden for pre-release numeric identifiers (per SemVer spec)
      if context == .preRelease, identifier.allSatisfy(isASCIINumber), identifier.count > 1, identifier.hasPrefix("0") {
        throw TextError(text: "Leading zeros in numeric pre-release identifier: \(identifier)")
      }
    }
  }
  
  private enum IdentifiersKind {
    case preRelease
    case buildMetadata
  }
}

extension SemVer: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.major == rhs.major &&
    lhs.minor == rhs.minor &&
    lhs.patch == rhs.patch &&
    lhs.preRelease == rhs.preRelease
  }
}

extension SemVer: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    // 1. Compare core version numerically: major > minor > patch
    if lhs.major != rhs.major { return lhs.major < rhs.major }
    if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
    if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
    
    // 2. Pre-release has lower precedence than release (per spec §11.3)
    let lhsIsRelease = lhs.preRelease.isEmpty
    let rhsIsRelease = rhs.preRelease.isEmpty
    
    if lhsIsRelease != rhsIsRelease {
      return !lhsIsRelease
    }
    
    // Both are releases → equal
    if lhsIsRelease { return false }
    
    // 3. Both pre-releases: compare identifiers left-to-right (per spec §11.4)
    return comparePreRelease(lhs.preRelease, rhs.preRelease)
  }
  
  /// Compares two pre-release identifier arrays per SemVer spec §11.4:
  /// - Numeric identifiers compared numerically
  /// - Alphanumeric compared lexically in ASCII order
  /// - Numeric < Alphanumeric
  /// - More identifiers wins if prefix equal
  private static func comparePreRelease(_ lhs: [String], _ rhs: [String]) -> Bool {
    let count = min(lhs.count, rhs.count)
    for i in 0..<count {
      let l = lhs[i]
      let r = rhs[i]
      let lNumeric = l.allSatisfy(isASCIINumber)
      let rNumeric = r.allSatisfy(isASCIINumber)
      
      if lNumeric && rNumeric {
        // Both numeric: compare as integers
        let lv = Int(l) ?? 0
        let rv = Int(r) ?? 0
        if lv != rv { return lv < rv }
      } else if lNumeric != rNumeric {
        // Numeric < Alphanumeric (per spec §11.4.2)
        return lNumeric
      } else {
        // Both alphanumeric: ASCII lexical comparison
        if l != r { return l < r }
      }
    }
    // Prefix equal: more identifiers wins (per spec §11.4.3)
    return lhs.count < rhs.count
  }
}

extension SemVer: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    self = try SemVer.parse(string)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }
}
