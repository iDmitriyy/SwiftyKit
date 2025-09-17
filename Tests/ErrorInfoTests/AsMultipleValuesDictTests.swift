//
//  AsMultipleValuesDictTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 17/09/2025.
//

@testable import ErrorInfo
import Testing
import Collections

struct AsMultipleValuesDictTests {
  func check<Key: Hashable, Value>(_ instance: some ErrorInfoMultipleValuesForKeyMergeable<Key, Value> & ErrorInfoPartialCollection) {
    let a: [Key: Array<Value>] = instance.asMultipleValuesAnyDict(omitEqualValue: false)
    let b: [Key: Deque<Value>] = instance.asMultipleValuesAnyDict(omitEqualValue: false)
    
    let c: OrderedDictionary<Key, Array<Value>> = instance.asMultipleValuesAnyDict(omitEqualValue: false)
    let d: OrderedDictionary<Key, Deque<Value>> = instance.asMultipleValuesAnyDict(omitEqualValue: false)
    
    // let _: [Key: OrderedSet<Value>] = instance.asMultipleValuesAnyDict(omitEqualValue: false)
    
    // let _: [Data: Array<String>] = // binary key
  }
}
