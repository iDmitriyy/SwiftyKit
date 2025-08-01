//
//  ErrorInfoSubscriptTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 01/08/2025.
//

@testable import ErrorInfo
import Testing

struct ErrorInfoSubscriptTests {
  @Test func subscriptKeyCollisionsForEqualValues() async throws {
    var errorInfo = ErrorInfo()
    let key = "key"
    errorInfo[key] = 0
    errorInfo[key] = 0
    errorInfo[key] = 0
    
    #expect(errorInfo.asStringDict().keys.count == 1)
  }
  
  @Test func subscriptKeyCollisionsForNotEqualValues() async throws {
    var errorInfo = ErrorInfo()
    let key = "key"
    errorInfo[key] = 0
    errorInfo[key] = 1
    errorInfo[key] = 2
    
    let keys = errorInfo.asStringDict().keys.sorted(by: { $0.count < $1.count })
    #expect(keys.count == 3)
    #expect(keys[0].count == 3)
    #expect(keys[1].count == 7)
    #expect(keys[2].count == 7) // FIXME: flaky test, if second key2 will collide with key1, then key2 will have cunt = 10
    
    // 0 : "key"
    // 1 : "key$lia"
    // 2 : "key$Qet"
  }
}
