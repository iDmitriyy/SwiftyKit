//
//  MultiValueErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import OrderedCollections
import IndependentDeclarations
import NonEmpty

/// If a key collision happens, the values are put into a container
struct MultiValueErrorInfo {
  private typealias _Element = Either<any ErrorInfoValueType, NonEmptyArray<any ErrorInfoValueType>>
  
  private var storage: OrderedDictionary<String, _Element> = [:]
  
  mutating func _addResolvingCollisions(value: any ErrorInfoValueType, forKey key: String) {
    if let existing = storage[key] {
      switch existing {
      case .left(let currentValue):
        if ErrorInfoFuncs.isApproximatelyEqual(currentValue, value) {
          ()
        } else {
          let array = NonEmptyArray(currentValue, value)
          storage[key] = .right(array)
        }
      case .right(let array):
        if !array.contains(where: { ErrorInfoFuncs.isApproximatelyEqual($0, value) }) {
          var array = array
          array.append(value)
          storage[key] = .right(array)
        }
      }
    } else {
      storage[key] = .left(value)
    }
  }
}

extension MultiValueErrorInfo {
  public mutating func addKeyPrefix(_ keyPrefix: String, fileLine: StaticFileLine = .this()) {
    fatalError()
  }
  
  public mutating func merge<each D>(_ donators: repeat each D) where repeat each D: ErrorInfoCollection {
    fatalError()
  }
}
