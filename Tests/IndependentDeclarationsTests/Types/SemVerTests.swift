//
//  SemVerTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 02.10.2026.
//

import Foundation
@testable import IndependentDeclarations
import Testing

/// SemVer 2.0.0 Spec Requirements
///
/// # Core Version (X.Y.Z)
/// - ✅ Major, minor, patch as non-negative integers
/// - ✅ No leading zeros (except "0" itself)
/// - ✅ Exactly 3 components
///
/// # Pre-release
/// - ✅ Hyphen-separated after patch
/// - ✅ Dot-separated identifiers
/// - ✅ Identifiers: ASCII alphanumerics + hyphen [0-9A-Za-z-]
/// - ✅ Identifiers MUST NOT be empty
/// - ✅ Numeric identifiers MUST NOT have leading zeros
/// - ✅ Pre-release has lower precedence than release
/// - ✅ Numeric identifiers compared numerically
/// - ✅ Alphanumeric compared lexically in ASCII order
/// - ✅ Numeric < Alphanumeric
/// - ✅ More identifiers is considered "greater than" if prefix equal
///
/// # Build Metadata
/// - ✅ Plus-separated after patch or pre-release
/// - ✅ Dot-separated identifiers
/// - ✅ Identifiers: ASCII alphanumerics + hyphen [0-9A-Za-z-]
/// - ✅ Identifiers MUST NOT be empty
/// - ✅ Leading zeros ALLOWED (unlike pre-release)
/// - ✅ Build metadata IGNORED in precedence
///
/// # Precedence (Comparison)
/// - ✅ Major > Minor > Patch numeric
/// - ✅ Pre-release < Release when core equal
/// - ✅ Pre-release identifiers compared left-to-right
/// - ✅ Numeric < Alphanumeric
/// - ✅ More identifiers is considered "greater than" if prefix equal
/// - ✅ Build metadata ignored
///
/// # Special Cases
/// - ✅ Version 0.y.z (initial development)
/// - ✅ Version 1.0.0 (public API)
struct SemVerTests {
  @Test func initAndDescription() throws {
    let v000 = SemVer(major: 0, minor: 0, patch: 0)
    let v010 = SemVer(major: 0, minor: 1, patch: 0)
    let v100 = SemVer(major: 1, minor: 0, patch: 0)
    let v123a = try SemVer(major: 1, minor: 2, patch: 3, preRelease: ["alpha1", "1"], buildMetadata: [])
    let v100b = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["beta-", "1"], buildMetadata: ["build", "123"])
    let vMaxA = try SemVer(major: .max, minor: .max, patch: .max, preRelease: ["alpha1", "1"], buildMetadata: [])

    #expect(v000.description == "0.0.0")
    #expect(v010.description == "0.1.0")
    #expect(v100.description == "1.0.0")
    #expect(v123a.description == "1.2.3-alpha1.1")
    #expect(v100b.description == "1.0.0-beta-.1+build.123")
    #expect(vMaxA.description == "65535.65535.65535-alpha1.1")
  }

  @Test func `String Parsing Core Version RoundTrip`() throws {
    let suffixes: [String] = [
      "", // empty string to test pure core version
      "-1beta-1.--1+exp.sha-2--.5114f85",
    ]
    
    let numbers: [UInt16] = [0, 1, 2, 3, 10, 11, 100, 101, 1000, .max]
    for major in numbers {
      for minor in numbers {
        for patch in numbers {
          let versionCoreString = "\(major).\(minor).\(patch)"

          for suffix in suffixes {
            let versionString = versionCoreString + suffix
            try Self.testRoundTrip(semVerString: versionString)
          }
        }
      }
    }
  }
  
  @Test func `String Parsing Valid Suffix RoundTrip`() throws {
    let coreVersions: [String] = [
      "0.0.0", "0.1.0", "1.0.0", "1.2.3", "9.9.9", "10.20.30", "100.0.0", "0.0.100", "100.101.102", "65535.65535.65535"
    ]
    
    let validSuffixes: [String] = [
      "-alpha",
      "-alpha.1",
      "+01",
      "+123",
      "+build.123",
      "-alpha+build.123",
      "-beta.1+exp.sha.5114f85",
      
      // valid but weird:
      "-alpha-",
      "--alpha", // Valid per grammar but likely a typo
      "-1alpha-01",
      "--", // Valid per grammar but likely meaningless in practice
      "-alpha-gamma.1--+build.123",
    ]
    
    for coreVersion in coreVersions {
      for suffix in validSuffixes {
        let versionString = coreVersion + suffix
        try Self.testRoundTrip(semVerString: versionString)
      }
    }
  }
  
  @Test func `String Parsing Invalid Strings Are Rejected`() throws {
    let invalid = ["", ".", "..", "...", "1", "1.", "1.2", "1.2.", "1.2.3.", "1.2.3.4"]
      + ["a.b.c", "1.0.0-🤡", "1.0.0+🤡"]
      + ["1.2.3.-", "1.2.3.+", "1.0.0..", "1.0.0..-", "1.0.0..+"]
      + ["1.0.0-", "1.0.0-.", "1.0.0+", "1.0.0+.", "1.0.0-.1", "1.0.0-.alpha"]
      + ["1.0.0-a..", "1.0.0+b..", "1.0.0-alpha+."]
      + ["01.0.0", "1.00.0", "1.0.01", "1.0.0-01", "1.0.0-alpha.01"]
      + ["0.0.1++build.123", "0.0.1-beta.1++exp.sha.5114f85"]
    
    for input in invalid {
      #expect(SemVer(input) == nil, "Should be nil for: \(input)")
      #expect(throws: (any Error).self) { try SemVer(description: input) }
    }
  }

  @Test func `validation Rejects Invalid Chars`() throws {
    #expect(throws: (any Error).self) { try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["a_b"], buildMetadata: []) }
    #expect(throws: (any Error).self) { try SemVer(major: 1, minor: 0, patch: 0, preRelease: [], buildMetadata: ["a b"]) }
    #expect(throws: (any Error).self) { try SemVer(description: "1.0.0-a_b") }
    #expect(throws: (any Error).self) { try SemVer(description: "1.0.0+a b") }
  }

  @Test func `validation Allows Hyphens In Identifiers`() throws {
    let v1 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["1alpha-01"], buildMetadata: [])
    #expect(v1.preRelease == ["1alpha-01"])
    let v2 = try SemVer(description: "1.0.0+1build-123.sha-abc")
    #expect(v2.buildMetadata == ["1build-123", "sha-abc"])
  }

  @Test func `validation Allows Empty Arrays In Init`() throws {
    let v = try SemVer(major: 1, minor: 0, patch: 0, preRelease: [], buildMetadata: [])
    #expect(v.preRelease.isEmpty && v.buildMetadata.isEmpty)
  }

  @Test func `comparison Case Sensitivity`() throws {
    let vA = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["A"], buildMetadata: [])
    let va = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["a"], buildMetadata: [])
    #expect(vA < va)
  }
  
  @Test func `equality Ignores BuildMetadata`() throws {
    let v1 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["1alpha-01"], buildMetadata: ["build1"])
    let v2 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["1alpha-01"], buildMetadata: ["build2"])
    let v3 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["beta"], buildMetadata: ["build1"])
    #expect(v1 == v2)
    #expect(v1 != v3)
  }

  @Test func `comparison Ignores BuildMetadata`() throws {
    let v1 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["aaa"])
    let v2 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["zzz"])
    #expect(!(v1 < v2) && !(v2 < v1) && v1 == v2)
  }

  @Test func `long Identifiers Supported`() throws {
    let long = String(repeating: "a", count: 257)
    let v100 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: [long], buildMetadata: [long])

    let preRelease = try #require(v100.preRelease.first)
    let buildMetadata = try #require(v100.buildMetadata.first)

    #expect(preRelease.count == 257)
    #expect(buildMetadata.count == 257)
  }

  @Test func `Codable RoundTrip`() throws {
    let original = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["beta", "1"], buildMetadata: ["build", "123"])
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(SemVer.self, from: data)
    #expect(decoded == original)
    #expect(decoded.description == original.description)
  }

  @Test func `Comparison Of CoreVersions`() throws {
    let sorted = [
      SemVer(major: 0, minor: 0, patch: 0),
      SemVer(major: 0, minor: 0, patch: 1),
      SemVer(major: 0, minor: 1, patch: 0),
      SemVer(major: 1, minor: 0, patch: 0),
      SemVer(major: 2, minor: 0, patch: 0),
      SemVer(major: 2, minor: 1, patch: 0),
      SemVer(major: 2, minor: 1, patch: 1),
      SemVer(major: 2, minor: 9, patch: 0),
      SemVer(major: 2, minor: 17, patch: 0),
      SemVer(major: .max, minor: .max, patch: .max),
    ]
    for i in sorted.indices.dropLast() {
      Self.expectIsLess(a: sorted[i], thanB: sorted[i + 1])
    }

    let last = try #require(sorted.last)
    Self.expectIsEqual(last)
  }

  /// https://semver.org/#:~:text=equal.-,Example:%201.0.0%2Dalpha%20%3C,rc.1%20%3C%201.0.0.
  @Test func `Comparison Of PreReleaseExamples From Site`() throws {
    let sorted = try [
      SemVer._makeFromString("1.0.0-alpha+9"),
      SemVer._makeFromString("1.0.0-alpha.1+7"),
      SemVer._makeFromString("1.0.0-alpha.beta+4"),
      SemVer._makeFromString("1.0.0-beta+10"),
      SemVer._makeFromString("1.0.0-beta.2+3"),
      SemVer._makeFromString("1.0.0-beta.2.1+0"),
      SemVer._makeFromString("1.0.0-beta.11+5"),
      SemVer._makeFromString("1.0.0-rc.1+8"),
      SemVer._makeFromString("1.0.0+2"),
      SemVer._makeFromString("1.1.0-alpha+1"),
    ]
    
    for i in sorted.indices.dropLast() {
      Self.expectIsLess(a: sorted[i], thanB: sorted[i + 1])
    }

    let last = try #require(sorted.last)
    Self.expectIsEqual(last)
  }
  
  @Test func specExamplesFromSite() throws {
    // Examples from semver.org spec
    let specExamples = [
      // pre release
      "1.0.0-alpha",
      "1.0.0-alpha.1",
      "1.0.0-0.3.7",
      "1.0.0-x.7.z.92",
      "1.0.0-x-y-z.--",
      // build metadata
      "1.0.0-alpha+001",
      "1.0.0+20130313144700",
      "1.0.0-beta+exp.sha.5114f85",
      "1.0.0+21AF26D3----117B344092BD",
    ]
    
    for example in specExamples {
      try Self.testRoundTrip(semVerString: example)
    }
  }
  
  @Test func examples() throws {
    let examples: [String] = [
      "1.9.0-beta+8547", // beta, Build 8547
      "1.9.0-rc.1+8553", // release candidate 1, Build 8553
      "1.9.0-rc.2+8554", // release candidate 2, Build 8554
      "1.9.0+8559", // release, Build 8559
      "1.9.0+8560", // release, Build 8560
    ]
    
    for example in examples {
      try Self.testRoundTrip(semVerString: example)
    }
  }
}

// MARK: - Tooling

extension SemVerTests {
  private static func testRoundTrip(semVerString: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
    let parsed = try SemVer._makeFromString(semVerString)
    
    let reconstructed = try SemVer(major: parsed.major,
                                   minor: parsed.minor,
                                   patch: parsed.patch,
                                   preRelease: parsed.preRelease,
                                   buildMetadata: parsed.buildMetadata)
    
    #expect(parsed == reconstructed)
    
    #expect(parsed.description == semVerString, "Description mismatch for: \(semVerString)")
    #expect(reconstructed.description == semVerString, "Description mismatch for: \(semVerString)")
  }
  
  private static func expectIsLess(a: SemVer, thanB b: SemVer, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(a < b, sourceLocation: sourceLocation)
    #expect(a <= b, sourceLocation: sourceLocation)
    #expect(b > a, sourceLocation: sourceLocation)
    #expect(b >= a, sourceLocation: sourceLocation)
    #expect(!(b < a), sourceLocation: sourceLocation)
    #expect(!(b <= a), sourceLocation: sourceLocation)
    #expect(a != b, sourceLocation: sourceLocation)
    #expect(!(a == b), sourceLocation: sourceLocation)

    #expect(a == a)
    #expect(a <= a)
    #expect(a >= a)
  }

  private static func expectIsEqual(_ element: SemVer, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(element <= element, sourceLocation: sourceLocation)
    #expect(element >= element, sourceLocation: sourceLocation)
    #expect(element == element, sourceLocation: sourceLocation)
  }
}

private extension SemVer {
  /// Uses both string initializers to test them together
  static func _makeFromString(_ description: String) throws -> Self {
    let failableInitInstance = try #require(Self(description))
    let throwableInitInstance = try Self(description: description)

    try #require(failableInitInstance == throwableInitInstance)
    try #require(failableInitInstance.description == throwableInitInstance.description)
    return Bool.random() ? failableInitInstance : throwableInitInstance
  }
}
