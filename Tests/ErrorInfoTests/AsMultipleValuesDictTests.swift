//
//  AsMultipleValuesDictTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 17/09/2025.
//

@testable import ErrorInfo
import Testing
import Collections
import NonEmpty

struct AsMultipleValuesDictTests {
  func check<Key: Hashable, Value>(_ instance: some ErrorInfoMultipleValuesForKeyStrategy<Key, Value> & ErrorInfoPartialCollection) {
    typealias NonEmptyDeque<T> = NonEmpty<Deque<T>>
    
    let sdar: [Key: NonEmptyArray<Value>] = instance.asMultipleValuesGenericDict(omitEqualValue: false)
    let sdde: [Key: NonEmptyDeque<Value>] = instance.asMultipleValuesGenericDict(omitEqualValue: false)
    
    let odar: OrderedDictionary<Key, NonEmptyArray<Value>> = instance.asMultipleValuesGenericDict(omitEqualValue: false)
    let odde: OrderedDictionary<Key, NonEmptyDeque<Value>> = instance.asMultipleValuesGenericDict(omitEqualValue: false)
    
    // let sdos: [Key: OrderedSet<Value>] = instance.asMultipleValuesAnyDict(omitEqualValue: false)
    
    // let _: [Data: Array<String>] = // binary data key
  }
}
