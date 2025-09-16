//
//  ErrorInfoSubscriptTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 01/08/2025.
//

@testable import ErrorInfo
import Testing
import Foundation

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
    
    let suffixFirstChar = "$"
    #expect(keys[0].count == 3)
    #expect(keys[1].count == 7 && keys[1].contains("$"))
    // as suffix is generated randomly, there is a chance that firstly generated suffix for key2 will be equal for key1
    // if second key2 will collide with key1, then key2 will have cunt = 10
    #expect((keys[2].count == 7 || keys[2].count == 10) && keys[2].contains("$"))
    // 0 : "key"
    // 1 : "key$lia"
    // 2 : "key$Qet"
  }
}

struct ErrorInfoDictionaryLiteralTests {
  @Test func initFromLiteral() async throws {
    let errorInfo: ErrorInfo = [
      "0": Optional.some(0),
      "1": Optional.some("1"),
      "2": Optional<Int>.none,
    ]
    
    errorInfo.asStringDict().count == 3
  }
}
