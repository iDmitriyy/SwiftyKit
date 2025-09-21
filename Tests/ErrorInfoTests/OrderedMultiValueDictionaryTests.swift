//
//  OrderedMultiValueDictionaryTests.swift
//  swifty-kit
//
//  Created by tmp on 21/09/2025.
//

@testable import ErrorInfo
import Testing
import StdLibExtensions
import OrderedCollections

struct OrderedMultiValueDictionaryTests {
//  @Test func `test values order`() throws {
//
//  }
  
  @Test func `test Empty Dictionary`() {
    let dict = OrderedMultiValueDictionary<String, Int>()
    #expect(dict.isEmpty)
    #expect(!dict.hasValue(forKey: "a"))
    #expect(dict.allValuesView(forKey: "a") == nil)
    #expect(dict["a"] == nil)
  }
  
  @Test func `test Append SingleValue`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    dict.append(key: "a", value: 1)

    #expect(dict.count == 1)
    #expect(dict.hasValue(forKey: "a"))
      
    let values = dict.allValuesView(forKey: "a")?.map { $0 }
    #expect(values == [1])
      
    let subscriptValues = dict["a"]?.map { $0 }
    #expect(subscriptValues == [1])
  }

  @Test func `test Append Multiple Values For The Same Key`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    dict.append(key: "a", value: 1)
    dict.append(key: "a", value: 2)
    dict.append(key: "a", value: 3)

    #expect(dict.count == 3)
    let values = dict.allValuesView(forKey: "a")?.map { $0 }
    #expect(values == [1, 2, 3])
  }

  @Test func `test Append Multiple Keys`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    dict.append(key: "a", value: 1)
    dict.append(key: "b", value: 2)
    dict.append(key: "a", value: 3)

    #expect(dict.count == 3)
    #expect(dict.allValuesView(forKey: "a")?.map { $0 } == [1, 3])
    #expect(dict.allValuesView(forKey: "b")?.map { $0 } == [2])
  }

  @Test func `test RemoveAllValues For Key`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    dict.append(key: "a", value: 1)
    dict.append(key: "a", value: 2)
    dict.append(key: "b", value: 3)

    dict.removeAllValues(forKey: "a")

    #expect(!dict.hasValue(forKey: "a"))
    #expect(dict.allValuesView(forKey: "a") == nil)
    #expect(dict.count == 1)
  }

  @Test func `test RemoveAll`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    dict.append(key: "a", value: 1)
    dict.append(key: "b", value: 2)

    dict.removeAll()

    #expect(dict.count == 0)
    #expect(!dict.hasValue(forKey: "a"))
    #expect(!dict.hasValue(forKey: "b"))
  }

  @Test func `test Iteration Order`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    
    typealias Element = (String, Int)
    let a0: Element = ("a", 0)
    let b1: Element = ("b", 1)
    let a2: Element = ("a", 2)
    let c3: Element = ("c", 3)
    let a4: Element = ("a", 4)
    
    dict.append(a0)
    dict.append(b1)
    dict.append(a2)
    dict.append(c3)
    dict.append(a4)

    let keyValues = Array(dict)
    #expect(keyValues.count == 5)
    #expect(keyValues[0] == a0)
    #expect(keyValues[1] == b1)
    #expect(keyValues[2] == a2)
    #expect(keyValues[3] == c3)
    #expect(keyValues[4] == a4)
  }

  @Test func `test Keys Property`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    dict.append(key: "a", value: 1)
    dict.append(key: "b", value: 2)
    dict.append(key: "a", value: 3)

    let keys = Set(dict.keys)
    #expect(keys == Set(["a", "b"]))
  }
}

extension OrderedMultiValueDictionaryTests {
  // MARK: 1. Property-Based Tests
  
  @Test func `test Count Matches Entries`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    
    var expectedCount = 0
    for i in 0..<10 {
      dict.append(key: "k\(i % 3)", value: i)
      expectedCount += 1
    }
    
    #expect(dict.count == expectedCount)
    
    let actualCount = Array(dict).count
    #expect(actualCount == expectedCount)
  }

  @Test func `test Keys Match Inserted Keys`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    let keys = ["a", "b", "c", "d", "e", "f", "g"] + ["a", "b"]
    
    for (i, key) in keys.enumerated() {
      dict.append(key: key, value: i)
    }
    
    let expectedKeys = OrderedSet(keys)
    let actualKeys = OrderedSet(dict.keys)
    #expect(expectedKeys == actualKeys)
  }
  
  // MARK: 2. Removal Behavior Tests
  
  @Test func `test Removing Key Reduces Count`() {
    var dict = OrderedMultiValueDictionary<String, Int>()
    dict.append(key: "a", value: 1)
    dict.append(key: "a", value: 2)
    dict.append(key: "b", value: 3)

    #expect(dict.count == 3)

    dict.removeAllValues(forKey: "a")

    #expect(dict.count == 1)
    #expect(!dict.hasValue(forKey: "a"))
    #expect(dict.hasValue(forKey: "b"))
  }
}

extension OrderedMultiValueDictionaryTests {
  // 1. Codable Conformance Tests
  
  // Only include if OrderedMultiValueDictionary conforms to Codable
//  func testCodableRoundTrip() throws {
//    var dict = OrderedMultiValueDictionary<String, Int>()
//    dict.append(key: "a", value: 1)
//    dict.append(key: "b", value: 2)
//    dict.append(key: "a", value: 3)
//
//    let encoded = try JSONEncoder().encode(dict)
//    let decoded = try JSONDecoder().decode(OrderedMultiValueDictionary<String, Int>.self, from: encoded)
//
//    XCTAssertEqual(Array(dict), Array(decoded))
//  }
  
//  func testDebugDescription() {
//    var dict = OrderedMultiValueDictionary<String, Int>()
//    dict.append(key: "a", value: 1)
//    dict.append(key: "b", value: 2)
//
//    let debugDescription = dict.debugDescription
//    XCTAssertTrue(debugDescription.contains("a"))
//    XCTAssertTrue(debugDescription.contains("1"))
//    XCTAssertTrue(debugDescription.contains("b"))
//    XCTAssertTrue(debugDescription.contains("2"))
//  }
}

// MARK: 3. Internal NonEmptyOrderedIndexSet Tests

struct NonEmptyOrderedIndexSetTests {
  @Test func `test SingleToMultiple Transition`() {
    var indexSet: NonEmptyOrderedIndexSet = .single(index: 1)
    indexSet.insert(3)

    switch indexSet {
    case .single:
      Issue.record("Expected to transition to .multiple")
    case .multiple(let indices):
      #expect(indices.apply(Array.init) == [1, 3])
    }
  }

  @Test func `test MultipleInsertPreserves Order`() {
    var indexSet: NonEmptyOrderedIndexSet = .single(index: 2)
    indexSet.insert(4)
    indexSet.insert(6)
    indexSet.insert(6)

    #expect(indexSet.apply(Array.init) == [2, 4, 6])
  }
}
