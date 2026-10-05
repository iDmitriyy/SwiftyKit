//
//  SemVer.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 01.10.2026.
//

/// Semantic Versioning 2.0.0 implementation.
/// See https://semver.org/spec/v2.0.0.html
public struct SemVer: Sendable, Comparable, LosslessStringConvertible {
  public let major: UInt64
  public let minor: UInt64
  public let patch: UInt64
  public let preRelease: [Identifier]
  public let buildMetadata: [Identifier]
  
  public var description: String {
    var result = "\(major).\(minor).\(patch)"
    if !preRelease.isEmpty {
      result += "-" + preRelease.lazy.map { $0.description }.joined(separator: ".")
    }
    if !buildMetadata.isEmpty {
      result += "+" + buildMetadata.lazy.map { $0.description }.joined(separator: ".")
    }
    return result
  }

  public init(major: UInt64, minor: UInt64, patch: UInt64, preRelease: [String], buildMetadata: [String]) throws {
    try self.init(_major: major, _minor: minor, _patch: patch, preRelease: preRelease, buildMetadata: buildMetadata)
  }
  
  private init<S>(_major: UInt64, _minor: UInt64, _patch: UInt64, preRelease: [S], buildMetadata: [S]) throws
    where S: StringProtocol {
    self.preRelease = try preRelease.map { try Identifier($0, context: .preRelease) }
    self.buildMetadata = try buildMetadata.map { try Identifier($0, context: .buildMetadata) }
    self.major = _major
    self.minor = _minor
    self.patch = _patch
  }

  public init(major: UInt64, minor: UInt64, patch: UInt64) {
    preRelease = []
    buildMetadata = []
    self.major = major
    self.minor = minor
    self.patch = patch
  }
  
  public init?(_ description: String) {
    try? self.init(description: description)
  }
  
  public init(description: String) throws {
    self = try SemVer.parse(description)
  }

  private static func parse(_ versionString: String) throws -> SemVer {
    var remaining = Substring(versionString)
    
    let rawBuildMetadata: [Substring]
    if let plusIndex = remaining.firstIndex(of: "+") {
      let buildPart = remaining[remaining.index(after: plusIndex)...]
      rawBuildMetadata = buildPart.split(separator: ".", omittingEmptySubsequences: false)
      remaining = remaining[..<plusIndex]
    } else {
      rawBuildMetadata = []
    }
    // FIXME: - remaining = String(remaining[..<plusIndex]) – non need to reinit String, just use Substring
    let rawPreRelease: [Substring]
    if let dashIndex = remaining.firstIndex(of: "-") {
      let prePart = remaining[remaining.index(after: dashIndex)...]
      rawPreRelease = prePart.split(separator: ".", omittingEmptySubsequences: false)
      remaining = remaining[..<dashIndex]
    } else {
      rawPreRelease = []
    }

    let coreComponents = remaining.split(separator: ".", omittingEmptySubsequences: false)
    guard coreComponents.count == 3 else {
      throw TextError(text: "Invalid version core: expected 3 components, got \(coreComponents.count) in \(versionString)")
    }
    
    return try SemVer(_major: try parseCoreVersionUInt(coreComponents[0], componentName: "major"),
                      _minor: try parseCoreVersionUInt(coreComponents[1], componentName: "minor"),
                      _patch: try parseCoreVersionUInt(coreComponents[2], componentName: "patch"),
                      preRelease: rawPreRelease,
                      buildMetadata: rawBuildMetadata)
  }

  private static func parseCoreVersionUInt<U: FixedWidthInteger>(_ string: Substring,
                                                                 componentName name: String) throws -> U {
    guard !string.isEmpty else { throw TextError(text: "Empty \(name) component") }
    guard string.allSatisfy(SemVer._isASCIINumber) else {
      throw TextError(text: "Non-ASCII numeric \(name) component: \(string)")
    }
    guard string.count == 1 || !string.hasPrefix("0") else {
      throw TextError(text: "Leading zeros in \(name) component: \(string)")
    }
    guard let value = U(string) else { throw TextError(text: "\(name) component out of range: \(string)") }
    return value
  }

  /// Context for identifier validation (affects leading zero rules).
  fileprivate enum IdentifiersContext {
    case preRelease
    case buildMetadata
  }
}

// MARK: - Equatable

extension SemVer: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.major == rhs.major &&
      lhs.minor == rhs.minor &&
      lhs.patch == rhs.patch &&
      lhs.preRelease == rhs.preRelease
  }
}

// MARK: - Comparable

extension SemVer {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    // 1. Compare core version numerically: major > minor > patch
    if lhs.major != rhs.major { return lhs.major < rhs.major }
    if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
    if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }

    // 2. Pre-release has lower precedence than release (per spec §11.3)
    let lhsIsRelease = lhs.preRelease.isEmpty
    let rhsIsRelease = rhs.preRelease.isEmpty

    switch (lhsIsRelease, rhsIsRelease) {
    case (true, true): // both releases, equal
      return false

    case (false, false):
      // Both pre-releases: compare identifiers left-to-right (per spec §11.4)
      return comparePreRelease(lhs.preRelease, rhs.preRelease)

    case (true, false), (false, true): // exactly one is a release
      return !lhsIsRelease // release is greater
    }
  }

  /// Compares two pre-release identifier arrays per SemVer spec §11.4:
  /// - Numeric identifiers compared numerically
  /// - Alphanumeric compared lexicographically in ASCII order
  /// - Numeric < Alphanumeric
  /// - More identifiers is considered "greater than" if prefix equal
  private static func comparePreRelease(_ lhs: [Identifier], _ rhs: [Identifier]) -> Bool {
    let minEndIndex = min(lhs.endIndex, rhs.endIndex)

    for i in 0..<minEndIndex {
      let lhsId = lhs[i]
      let rhsId = rhs[i]

      // Identifier's Comparable already implements spec-compliant comparison
      if lhsId == rhsId {
        continue
      } else {
        return lhsId < rhsId
      }
    }

    // Prefix equal: more identifiers is considered "greater than" (per spec §11.4.3)
    return lhs.count < rhs.count
  }
}

// MARK: - Identifier

extension SemVer {
  /// A SemVer identifier, either numeric (UInt64) or alphanumeric (ascii String).
  public struct Identifier: Sendable, Comparable, CustomStringConvertible {
    let variant: Variant

    public var description: String {
      switch variant {
      case .numeric(let number): String(number)
      case .alphaNumeric(let string): string
      }
    }
    
    fileprivate init(_ identifier: some StringProtocol, context: IdentifiersContext) throws {
      guard !identifier.isEmpty else { throw TextError(text: "Empty identifier in \(context)") }
      guard identifier.allSatisfy(SemVer._isASCIIAlphaNumericOrHyphen) else {
        throw TextError(text: "Invalid character in \(context) identifier: \(identifier)")
      }

      let isNumeric = identifier.allSatisfy(SemVer._isASCIINumber)
      if isNumeric {
        guard let integer = UInt(identifier) else {
          throw TextError(text: "Numeric identifier out of range: \(identifier)")
        }

        if identifier.count > 1, identifier.hasPrefix("0") {
          switch context {
          case .buildMetadata:
            // UInt("01") is 1, but we need to preserve leading zero in buildMetadata.
            // so use string identifier instead of integer
            variant = .alphaNumeric(String(identifier))

          case .preRelease:
            // Leading zeros are forbidden for pre-release numeric identifiers (except single zero)
            throw TextError(text: "Leading zeros in numeric pre-release identifier: \(identifier)")
          }
        } else {
          variant = .numeric(integer)
        }
      } else {
        variant = .alphaNumeric(String(identifier))
      }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.variant, rhs.variant) {
      case let (.numeric(uLhs), .numeric(uRhs)): uLhs < uRhs
      case let (.alphaNumeric(sLhs), .alphaNumeric(sRHS)): sLhs < sRHS
      case (.numeric, .alphaNumeric): true // Numeric < Alphanumeric (per spec §11.4.2)
      case (.alphaNumeric, .numeric): false
      }
    }

    internal enum Variant: Sendable, Equatable {
      case numeric(UInt)
      case alphaNumeric(String)
    }
  }

  internal static func _isASCIINumber(_ character: Character) -> Bool {
    let utf8 = character.utf8
    guard let byte = utf8.first, utf8.count == 1 else { return false }
    return 48...57 ~= byte
  }

  internal static func _isASCIIAlphaNumericOrHyphen(_ character: Character) -> Bool {
    let utf8 = character.utf8
    guard let byte = utf8.first, utf8.count == 1 else { return false }
    // 48...57  -> '0'...'9'
    // 65...90  -> 'A'...'Z'
    // 97...122 -> 'a'...'z'
    // 45       -> '-'
    switch byte {
    case 48...57, 65...90, 97...122, 45: return true
    default: return false
    }
  }
}

// MARK: - Codable

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
