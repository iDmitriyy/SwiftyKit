//
//  MergeDictionaryTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

@testable import ErrorInfo
import Testing

struct MergeDictionaryTests {
  @Test func unsafeCast() async throws {
    let dd = asString(any: "ABCD")
    let ff = asString(any: [])
    _ = 0
  }
  
  @Test func noKeyMidification() async throws {
    var dict: [String: Int] = ["0": 0]
    let fileLine = StaticFileLine(fileID: "MergeDictionaryTests", line: 15)
    let omitEqualValue = true
    ErrorInfoDictFuncs.Merge
      .withResolvingCollisionsAdd(keyValue: ("0", 0),
                                  to: &dict,
                                  donatorIndex: 0,
                                  omitEqualValue: omitEqualValue,
                                  fileLine: fileLine,
                                  resolving: { input in
          .modifyDonatorKey(input.element.key)
      })
    ErrorInfoDictFuncs.Merge
      .withResolvingCollisionsAdd(keyValue: ("0", 0),
                                  to: &dict,
                                  donatorIndex: 1,
                                  omitEqualValue: omitEqualValue,
                                  fileLine: fileLine,
                                  resolving: { input in
          .modifyDonatorKey(input.element.key)
      })
  }
  
  @Test func omitEqualValuesFalse() async throws {
    // var info1: [String: Int] = [:]
    // var info2: [String: Int] = [:]
  }
  
  @Test func donatorIndexNotChanging() async throws {
    
  }
  
  @Test func modifiedKeyHasCollision() async throws {
    
  }
}

func asString<T>(any: T) -> String {
  if T.self == String.self {
    print("_____ unsafeBitCast")
    return unsafeBitCast(any, to: String.self)
  } else {
    return String(describing: any)
  }
}
