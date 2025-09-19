//
//  AsMultipleValuesDictTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 17/09/2025.
//

import Collections
@testable import ErrorInfo
import NonEmpty
import Testing

struct AsMultipleValuesDictTests {
  func check<Key: Hashable, Value>(_ instance: some ErrorInfoMultipleValuesForKeyStrategy<Key, Value> & ErrorInfoPartialCollection) {
    typealias NonEmptyDeque<T> = NonEmpty<Deque<T>>
    
    let sdar: [Key: NonEmptyArray<Value>] = instance.asMultipleValuesDictGeneric(omitEqualValue: false)
    let sdde: [Key: NonEmptyDeque<Value>] = instance.asMultipleValuesDictGeneric(omitEqualValue: false)
    
    let odar: OrderedDictionary<Key, NonEmptyArray<Value>> = instance.asMultipleValuesDictGeneric(omitEqualValue: false)
    let odde: OrderedDictionary<Key, NonEmptyDeque<Value>> = instance.asMultipleValuesDictGeneric(omitEqualValue: false)
    
    // let sdos: [Key: OrderedSet<Value>] = instance.asMultipleValuesAnyDict(omitEqualValue: false)
    
    // let _: [Data: Array<String>] = // binary data key
  }
}
