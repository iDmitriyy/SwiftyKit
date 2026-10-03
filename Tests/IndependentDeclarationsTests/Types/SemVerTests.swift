//
//  SemVerTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 02.10.2026.
//

import Foundation
@testable import IndependentDeclarations
import Testing

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

  @Test func parsingFromStringRoundTrip() throws {
    // preRelease / buildMetaData
    let validSuffixes: [String] = [
      "-alpha",
      "-alpha-",
      "--alpha", // Valid per grammar but likely typo
      "-alpha.1",
      "--", // Valid per grammar but likely meaningless in practice
      "+01",
      "+123",
      "+build.123",
      "-alpha+build.123",
      "-alpha-gamma.1--+build.123",
      "-beta.1+exp.sha.5114f85",
    ]

    let numbers: [UInt16] = [0, 1, 2, 3, 7, 10, 11, 100, 101, .max]
    for major in numbers {
      for minor in numbers {
        for patch in numbers {
          let versionCoreString = "\(major).\(minor).\(patch)"
          #expect(try SemVer._makeFromString(versionCoreString).description == versionCoreString,
                  "Description mismatch for: \(versionCoreString)")

          for suffix in validSuffixes {
            let versionString = versionCoreString + suffix
            #expect(try SemVer._makeFromString(versionString).description == versionString,
                    "Description mismatch for: \(versionString)")
          }
        }
      }
    }
  }
  
  private static func checkRoundTrip(semVerString: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
    let instance = try SemVer._makeFromString(semVerString)
    
    let instance2 = try SemVer(major: instance.major, minor: instance.minor, patch: instance.patch, preRelease: instance.preRelease, buildMetadata: instance.buildMetadata)
    
    #expect(instance == instance2)
    
    #expect(instance.description == semVerString, "Description mismatch for: \(semVerString)")
    #expect(instance2.description == semVerString, "Description mismatch for: \(semVerString)")
  }

  @Test func parsingInvalidStrings() throws {
    let invalid = ["", ".", "..", "...", "1", "1.", "1.2", "1.2.", "0.0.01", "1.2.3.4"]
      + ["1.2.3.", "1.2.3.-", "1.2.3.+", "1.0.0..", "1.0.0..-", "1.0.0..+"]
      + ["a.b.c", "1.0.0-🤡", "1.0.0+🤡"]
      + ["1.0.0-", "1.0.0-.", "1.0.0+", "1.0.0+.", "1.0.0-.1", "1.0.0-a..", "1.0.0+b..", "1.0.0-alpha+."]
      + ["01.0.0", "1.00.0", "1.0.01", "1.0.0-01"]
      + ["0.0.1++build.123", "0.0.1-beta.1++exp.sha.5114f85"]

    for input in invalid {
      #expect(SemVer(input) == nil, "Should be nil for: \(input)")
      #expect(throws: (any Error).self) { try SemVer(description: input) }
    }
  }

  @Test func `build metadata allow leading zeros`() throws {
    // Build metadata CAN have leading zeros (per spec)
    let va = try SemVer(major: 1, minor: 0, patch: 0, preRelease: [], buildMetadata: ["01"])
    #expect(va.buildMetadata == ["01"])

    let vb = try SemVer(description: "1.0.0+01")
    #expect(vb.buildMetadata == ["01"])
  }

  @Test func validationRejectsInvalidChars() throws {
    #expect(throws: (any Error).self) { try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["a_b"], buildMetadata: []) }
    #expect(throws: (any Error).self) { try SemVer(major: 1, minor: 0, patch: 0, preRelease: [], buildMetadata: ["a b"]) }
    #expect(throws: (any Error).self) { try SemVer(description: "1.0.0-a_b") }
    #expect(throws: (any Error).self) { try SemVer(description: "1.0.0+a b") }
  }

  @Test func validationAllowsHyphensInIdentifiers() throws {
    let v1 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha-1"], buildMetadata: [])
    #expect(v1.preRelease == ["alpha-1"])
    let v2 = try SemVer(description: "1.0.0+build-123.sha-abc")
    #expect(v2.buildMetadata == ["build-123", "sha-abc"])
  }

  @Test func validationAllowsEmptyArraysInInit() throws {
    let v = try SemVer(major: 1, minor: 0, patch: 0, preRelease: [], buildMetadata: [])
    #expect(v.preRelease.isEmpty && v.buildMetadata.isEmpty)
  }

  @Test func equalityIgnoresBuildMetadata() throws {
    let v1 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["build1"])
    let v2 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["build2"])
    let v3 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["beta"], buildMetadata: ["build1"])
    #expect(v1 == v2)
    #expect(v1 != v3)
  }

  @Test func comparisonCaseSensitivity() throws {
    #expect(try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["A"], buildMetadata: []) < SemVer(major: 1, minor: 0, patch: 0, preRelease: ["a"], buildMetadata: []))
  }

  @Test func comparisonBuildMetadataIgnored() throws {
    let v1 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["aaa"])
    let v2 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["zzz"])
    #expect(!(v1 < v2) && !(v2 < v1))
  }

  @Test func longIdentifiers() throws {
    let long = String(repeating: "a", count: 257)
    let v100 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: [long], buildMetadata: [long])

    let preRelease = try #require(v100.preRelease.first)
    let buildMetadata = try #require(v100.buildMetadata.first)

    #expect(preRelease.count == 257)
    #expect(buildMetadata.count == 257)
  }

  @Test func codableRoundTrip() throws {
    let original = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["beta", "1"], buildMetadata: ["build", "123"])
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(SemVer.self, from: data)
    #expect(decoded == original)
    #expect(decoded.description == original.description)
  }

  @Test func specExamplesFromSite() throws {
    // Examples directly from semver.org spec
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
      let parsed = try SemVer._makeFromString(example)
      #expect(parsed.description == example, "Spec example round-trip failed: \(example)")
    }
  }

  @Test func comparisonSortedCoreVersions() throws {
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
  @Test func comparisonPreReleaseExamplesFromSite() throws {
    let sorted = try [
      SemVer._makeFromString("1.0.0-alpha+9"),
      SemVer._makeFromString("1.0.0-alpha.1+7"),
      SemVer._makeFromString("1.0.0-alpha.beta+4"),
      SemVer._makeFromString("1.0.0-beta+10"),
      SemVer._makeFromString("1.0.0-beta.2+3"),
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

  private static func expectIsLess(a: SemVer, thanB b: SemVer, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(a < b, sourceLocation: sourceLocation)
    #expect(a <= b, sourceLocation: sourceLocation)
    #expect(b > a, sourceLocation: sourceLocation)
    #expect(b >= a, sourceLocation: sourceLocation)
    #expect(!(b < a), sourceLocation: sourceLocation)
    #expect(!(b <= a), sourceLocation: sourceLocation)
    #expect(!(a == b), sourceLocation: sourceLocation)
    #expect(a != b, sourceLocation: sourceLocation)

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
