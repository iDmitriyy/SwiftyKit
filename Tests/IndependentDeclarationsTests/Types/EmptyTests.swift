//
//  EmptyTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 08.04.2025.
//

@testable import IndependentDeclarations
import Testing

struct EmptyTests {
  @Test func hashAndEquality() throws {
    let a1 = Empty()
    let a2 = Empty()
    
    #expect(a1 == a2)
    #expect(a1.hashValue == a2.hashValue)
  }
  
  @Test func hashAndEqualityWhenWrapped() throws {
    let a1: Either<Empty, Empty> = .left(Empty())
    let a2: Either<Empty, Empty> = .left(Empty())
    
    #expect(a1 == a2)
    #expect(a1.hashValue == a2.hashValue)
    
    let left: Either<Empty, Empty> = .left(Empty())
    let right: Either<Empty, Empty> = .right(Empty())
    
    #expect(left != right)
    #expect(left.hashValue != right.hashValue)
  }
}
