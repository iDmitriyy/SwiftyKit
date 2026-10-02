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
    let v010 = SemVer(major: 0, minor: 1, patch: 0)
    let v100 = SemVer(major: 1, minor: 0, patch: 0)
    let v123a = try SemVer(major: 1, minor: 2, patch: 3, preRelease: ["alpha"], buildMetadata: [])
    let v100b = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["beta-", "1"], buildMetadata: ["build", "123"])

    #expect(v010.description == "0.1.0")
    #expect(v100.description == "1.0.0")
    #expect(v123a.description == "1.2.3-alpha")
    #expect(v100b.description == "1.0.0-beta-.1+build.123")
  }

  @Test func parsingFromStringRoundTrip() throws {
    // preRelease / buildMetaData
    let validSuffixes: [String] = [
      "-alpha",
      "-alpha.1",
      "-beta.2",
      "+123",
      "+build.123",
      "-alpha+build.123",
      "-alpha-gamma.1--+build.123",
      "-beta.1+exp.sha.5114f85",
    ]

    let numbers: [UInt8] = [0, 1, 2, 3, 7, 10, 11] // no need to spend time for checking full range 0...11
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

  @Test func parsingInvalidStrings() throws {
    let invalid = ["", ".", "..", "...", "1", "1.", "1.2", "1.2.", "1.2.3.", "0.0.01", "1.2.3.4"]
      + ["a.b.c", "1.0.0-", "1.0.0+", "1.0.0-.1", "1.0.0-a..", "1.0.0+b..", "1.0.0-🤡", "1.0.0+🤡"]
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

  @Test func comparisonPreReleaseVsRelease() throws {
    let release = SemVer(major: 1, minor: 0, patch: 0)
    let pre = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: [])
    #expect(pre < release)
    #expect(!(release < pre))
  }

  @Test func comparisonNumericVsAlphanumeric() throws {
    #expect(try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["1"], buildMetadata: []) < SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: []))
    #expect(try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["2"], buildMetadata: []) < SemVer(major: 1, minor: 0, patch: 0, preRelease: ["10"], buildMetadata: []))
  }

  @Test func comparisonCaseSensitivity() throws {
    #expect(try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["A"], buildMetadata: []) < SemVer(major: 1, minor: 0, patch: 0, preRelease: ["a"], buildMetadata: []))
  }

  @Test func comparisonBuildMetadataIgnored() throws {
    let v1 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["aaa"])
    let v2 = try SemVer(major: 1, minor: 0, patch: 0, preRelease: ["alpha"], buildMetadata: ["zzz"])
    #expect(!(v1 < v2) && !(v2 < v1))
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

  @Test func comparisonCoreVersionChain() {
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
    ]
    for i in sorted.indices.dropLast() {
      #expect(sorted[i] < sorted[i + 1])
      #expect(sorted[i + 1] > sorted[i])
    }
  }

  /// https://semver.org/#:~:text=equal.-,Example:%201.0.0%2Dalpha%20%3C,rc.1%20%3C%201.0.0.
  @Test func comparisonPreReleaseFromSite() throws {
    let sorted = try [
      SemVer._makeFromString("1.0.0-alpha"),
      SemVer._makeFromString("1.0.0-alpha.1"),
      SemVer._makeFromString("1.0.0-alpha.beta"),
      SemVer._makeFromString("1.0.0-beta"),
      SemVer._makeFromString("1.0.0-beta.2"),
      SemVer._makeFromString("1.0.0-beta.11"),
      SemVer._makeFromString("1.0.0-rc.1"),
      SemVer._makeFromString("1.0.0"),
      SemVer._makeFromString("1.1.0-alpha"),
    ]

    for i in sorted.indices.dropLast() {
      #expect(sorted[i] < sorted[i + 1])
      #expect(sorted[i + 1] > sorted[i])
    }
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
