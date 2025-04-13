//
//  EquatableExcludedTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 08.04.2025.
//

@testable import IndependentDeclarations
import Testing

struct EquatableExcludedTests {
  @Test func hashAndEquality() throws {
    let a1 = HashableExcluded("a")
    let a2 = HashableExcluded("b")
    
    #expect(a1 == a2)
    #expect(a1.hashValue == a2.hashValue)
  }
  
  @Test func hashAndEqualityWhenWrapped() throws {
    let a1: Either<HashableExcluded<String>, HashableExcluded<String>> = .left(HashableExcluded("a"))
    let a2: Either<HashableExcluded<String>, HashableExcluded<String>> = .left(HashableExcluded("b"))
    
    #expect(a1 == a2)
    #expect(a1.hashValue == a2.hashValue)
    
    let value = "c"
    let left: Either<HashableExcluded<String>, HashableExcluded<String>> = .left(HashableExcluded(value))
    let right: Either<HashableExcluded<String>, HashableExcluded<String>> = .right(HashableExcluded(value))
    
    #expect(left != right)
    #expect(left.hashValue != right.hashValue)
  }
}
