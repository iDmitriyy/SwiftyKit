//
//  ErrorInfoSubscriptTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 01/08/2025.
//

@testable import ErrorInfo
import Testing

struct ErrorInfoSubscriptTests {
  @Test func subscriptWithCollisions() async throws {
    var errorInfo = ErrorInfo()
    let key = "key"
    errorInfo[key] = 0
    errorInfo[key] = 1
    errorInfo[key] = 2
    
    let keys = errorInfo.asStringDict().keys
    
    #expect(keys.count == 3)
  }
}
