//
//  BundleTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 21.04.2025.
//

import Testing
@testable import FoundationExtensions

struct BundleExtensionTests {
  @Test func mainAppVersionString() {
    #expect(!Bundle.mainAppVersionString.isEmpty)
  }
    
  @Test func mainAppBuildNumberString() {
    #expect(!Bundle.mainAppBuildNumberString.isEmpty)
  }
    
  @Test func mainAppFullVersionString() {
    #expect(!Bundle.mainAppFullVersionString.isEmpty)
  }
    
  @Test func mainSemVerAppVersion() {
    #expect(Bundle.mainAppVersion >= SemVerAppVersion(major: 0, minor: 0, patch: 0))
  }
    
  @Test func mainAppBuildNumber() {
    #expect(Bundle.mainAppBuildNumber >= 0)
  }
}

struct SemVerAppVersionTests {
  @Test func initFromString() throws {
    let appVersionString = "1.0.0"
    
    let appVersion = try #require(SemVerAppVersion(appVersionString))
    XCTAssertNoThrow(try SemVerAppVersion(description: appVersionString))
    
    let description = String(describing: appVersion)
    XCTAssertEqual(appVersionString, description)
  }
    
  @Test func initFromInvalidString() {
    let appVersionInvalidString = "invalid version string"
    XCTAssertNil(SemVerAppVersion(appVersionInvalidString))
    XCTAssertThrowsError(try SemVerAppVersion(description: appVersionInvalidString))
  }
    
  @Test func equality() {
    let appVersion1 = SemVerAppVersion(major: 1, minor: 2, patch: 3)
    let appVersion2 = SemVerAppVersion(major: 1, minor: 2, patch: 3)
    XCTAssertEqual(appVersion1, appVersion2)
  }
    
  @Test func lessThan() {
    let appVersion1 = SemVerAppVersion(major: 1, minor: 2, patch: 3)
    let appVersion2 = SemVerAppVersion(major: 1, minor: 3, patch: 0)
    let appVersion3 = SemVerAppVersion(major: 1, minor: 11, patch: 0)
    XCTAssertTrue(appVersion1 < appVersion2)
    XCTAssertTrue(appVersion2 < appVersion3)
  }
    
  @Test func decoding() throws {
    let json = """
        [1,2,3]
    """
    let data = Data(json.utf8)
        
    let decoder = JSONDecoder()
    let appVersion = try decoder.decode(SemVerAppVersion.self, from: data)
        
    XCTAssertEqual(appVersion.major, 1)
    XCTAssertEqual(appVersion.minor, 2)
    XCTAssertEqual(appVersion.patch, 3)
  }
    
  @Test func ncoding() throws {
    let appVersion = SemVerAppVersion(major: 1, minor: 2, patch: 3)
        
    let encoder = JSONEncoder()
    let data = try encoder.encode(appVersion)
    
    let json = String(decoding: data, as: UTF8.self)
    let expectedJson = "[1,2,3]"
    XCTAssertEqual(json, expectedJson)
  }
}
