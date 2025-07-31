//
//  BundleTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 21.04.2025.
//

import Testing
@testable import FoundationExtensions
import Foundation

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
  
  #if !SWT_NO_EXIT_TESTS
    @Test func noCrash() async throws {
      let dd = await #expect(processExitsWith: .success) {
        let bundleId = Bundle.main.bundleId
        let mainAppBuildNumber = Bundle.mainAppBuildNumber
      }
      
    // TODO: check actual values, not Apple framework
      let bundleId = Bundle.main.bundleId // com.apple.dt.xctest.tool
      let mainAppBuildNumber = Bundle.mainAppBuildNumber // 24244
      
      _ = 0
    }
  #endif
}

struct SemVerAppVersionTests {
  @Test func initFromString() throws {
    let appVersionString = "1.0.0"
    
    let appVersion = try #require(SemVerAppVersion(appVersionString))
    
    let description = String(describing: appVersion)
    #expect(appVersionString == description)
  }
    
  @Test func initFromInvalidString() {
    let appVersionInvalidString = "invalid version string"
    #expect(SemVerAppVersion(appVersionInvalidString) == nil)
    #expect(throws: (any Error).self) { try SemVerAppVersion(description: appVersionInvalidString) }
  }
    
  @Test func equality() {
    let appVersion1 = SemVerAppVersion(major: 1, minor: 2, patch: 3)
    let appVersion2 = SemVerAppVersion(major: 1, minor: 2, patch: 3)
    #expect(appVersion1 == appVersion2)
  }
    
  @Test func lessThan() {
    let appVersion1 = SemVerAppVersion(major: 1, minor: 2, patch: 3)
    let appVersion2 = SemVerAppVersion(major: 1, minor: 3, patch: 0)
    let appVersion3 = SemVerAppVersion(major: 1, minor: 11, patch: 0)
    #expect(appVersion1 < appVersion2)
    #expect(appVersion2 < appVersion3)
  }
    
  @Test func decoding() throws {
    let json = """
        [1,2,3]
    """
    let data = Data(json.utf8)
        
    let decoder = JSONDecoder()
    let appVersion = try decoder.decode(SemVerAppVersion.self, from: data)
        
    #expect(appVersion.major == 1)
    #expect(appVersion.minor == 2)
    #expect(appVersion.patch == 3)
  }
    
  @Test func encoding() throws {
    let appVersion = SemVerAppVersion(major: 1, minor: 2, patch: 3)
        
    let encoder = JSONEncoder()
    let data = try encoder.encode(appVersion)
    
    let json = String(decoding: data, as: UTF8.self)
    let expectedJson = "[1,2,3]"
    #expect(json == expectedJson)
  }
}
