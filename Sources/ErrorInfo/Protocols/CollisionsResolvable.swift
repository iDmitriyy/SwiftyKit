//
//  CollisionsResolvable.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 18/09/2025.
//

// MARK: - Merge Operations

//protocol ErrorInfoCollisionsResolvable<Key, Value>: IterableErrorInfo {
//  init(_ keyValues: some Sequence<Element>)
//}
//
//extension ErrorInfoMergeOp {}

public protocol ErrorInfoCollisionsResolvable_<Key, Value>: ~Copyable where Key: Hashable { // : IterableErrorInfo
  associatedtype Key
  associatedtype Value
  typealias Element = (key: Key, value: Value)
  
  associatedtype KeyValues: Sequence<Element>
  /// some keys can be repeated several times, in other words keys are not guaranteed be unique
  var keyValuesView: KeyValues { get }
  
  init()
  init(minimumCapacity: Int)
  
  // TODO: ??! is it possible to implement with no additional args?
  // subscript can be used, but it is not guaranteed to resolve collisions
//  mutating func mergeWith(_ keyValues: some Sequence<Element>)
  
  /// has default imp
//  init(_ keyValues: some Sequence<Element>) // TODO: sequence may have duplicated keys
}

// MARK: Default implementations

extension ErrorInfoCollisionsResolvable_ {
//  public init(_ keyValues: some Sequence<Element>) {
//    self.init()
//    self.mergeWith(keyValues)
//  }
//
//  public consuming func mergedWith(_ keyValues: some Sequence<Element>) -> Self {
//    self.mergeWith(keyValues)
//    return self
//  }
}

//MARK: - Key Augmentation Collison Strategy

public protocol ErrorInfoUniqueKeysAugmentationStrategy<Key, Value>: ErrorInfoCollisionsResolvable_ {
  associatedtype OpaqueDictType: DictionaryUnifyingProtocol<Key, Value>
}

extension ErrorInfoUniqueKeysAugmentationStrategy {
//  static func merge(recipient: consuming some ErrorInfoMergeOp, donator: borrowing some IterableErrorInfo)
}

//MARK: - MultipleValues For Key Collison Strategy

public protocol ErrorInfoMultipleValuesForKeyStrategy<Key, Value>: ErrorInfoCollisionsResolvable_ {}
