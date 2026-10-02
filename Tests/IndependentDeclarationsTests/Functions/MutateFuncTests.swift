//
//  MutateFuncTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import Testing
@testable import IndependentDeclarations

struct MutateFuncTests {
  
  init() async throws {}

  @Test func menuBackgroundColor() { // async throws
//        #expect(collectionView.backgroundColor == .green)
  }
  
  @Test func testMutateWithValue() {
    let initialValue = 10
    let mutatedValue = mutated(value: initialValue) { $0 += 5 }
    
    #expect(mutatedValue == 15)
  }

  @Test func noMutationDone() {
    let initialValue = "Hello"
    let mutatedValue = mutated(value: initialValue) { _ in }
    #expect(mutatedValue == "Hello")
  }

  @Test func testMutateWithNilValue() {
    let mutatedValue = mutated(value: Optional<Int>.none as Any) { _ in }
    
    #expect((mutatedValue as? Int) == nil)
  }

  @Test func testMutateWithErrorMutation() {
    #expect(throws: (any Error).self) {
      try mutated(value: 5) { _ in throw NoMatterWhatError() }
    }
  }
  
  @Test func testMutateWithErrorValue() {
    #expect(throws: Never.self) {
      let value = try mutated(value: 5) { value throws(NoMatterWhatError) in value += 1 }
      #expect(value == 6)
    }
  }
  
  @Test func copyOnWrite() {
    let storedValue = ValueTypeWithCoW()
    let val1 = mutated(value: storedValue) { _ in
      
    }
    // value for func arg should be copied and this copy consumed, no additional copies made
    // val1.maxCounter == ??
    
    let val2 = mutated(value: ValueTypeWithCoW()) { _ in
      
    }
    // func arg should be consumed and no copies made
    // val2.maxCounter == ??
  }
  
  // MARK: - Below test made to check that code compiled with provided args
  
  @Test func apiSurface_AcceptNonCopyableArg() {
    let _ = mutated(value: NonCopyable(value: 0)) { $0.value += 1 }
    
    let instance = NonCopyable(value: 0)
    let muatatedInstance = mutated(value: instance) { $0.value += 1 }
    
    #expect(muatatedInstance.value == 1)
  }
  
  @Test("Warning should appear to handle that function should not be used with reference Type instances")
  func apiSurface_AnyObjectDeprecationWarning() {
    let _ = mutated(value: EmptyClass() as AnyObject) { _ in }
  }
  
  struct NonCopyable: ~Copyable {
    var value: Int
  }
  
  private struct NoMatterWhatError: Error {}
  
  struct ValueTypeWithCoW {
    init() {
      
    }
  }
  
  final class CoWCounter {
    
  }
  
  final class EmptyClass {}
}
