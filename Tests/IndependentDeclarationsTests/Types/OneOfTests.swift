//
//  OneOfTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

@testable import IndependentDeclarations
import Testing

struct OneOfTests {
  @Test func comparableOneOf2() throws {
    let value = OneOf2<Int, Int>.first(5)
    let anyValue = value as Any
    #expect(anyValue as? any Comparable != nil, "OneOf2 instance must be Comparable")
  }
}
