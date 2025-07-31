//
//  EitherTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

@testable import IndependentDeclarations
import Testing

struct EitherTests {
  @Test func notComparable() throws {
    let value = Either<Int, Int>.left(5)
    let anyValue = value as Any
    #expect(anyValue as? any Comparable == nil, "Either instance must not be Comparable")
    #expect(throws: Never.self) {
      
    }
  }
}
