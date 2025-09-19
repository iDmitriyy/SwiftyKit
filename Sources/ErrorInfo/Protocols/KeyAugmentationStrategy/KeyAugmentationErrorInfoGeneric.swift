//
//  KeyAugmentationErrorInfoGeneric.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 19/09/2025.
//

public import struct NonEmpty.NonEmpty

/// NoRemovingErrorInfo Is specially made for BaseError default merge algorythms.
/// As BaseError types can contain different error-info implementations, each instance can have different merge function.
// typealias NoRemovingErrorInfo<V> = _ErrorInfoGenericValue<V>

/// BaseError `summaryErrorInfo` should return Opaque type.
/// Each error-info type should have an ability to initialize from another one, like collections can be initialized from each other.

/// Generic backing storage for implementing error info types with `KeyAugmentation` strategy.
public struct KeyAugmentationErrorInfoGeneric<D> where D: DictionaryUnifyingProtocol, D.Key: RangeReplaceableCollection {
  public typealias Key = D.Key
  public typealias Value = D.Value
  public typealias Element = (key: Key, value: Value)
  
  internal private(set) var _dict: D
  
  public init() {
    _dict = D()
  }
  
  public init(_ dict: D) {
    _dict = dict
  }
  
  public func makeIterator() -> some IteratorProtocol<Element> {
    _dict.makeIterator()
  }
}

// MARK: - Mutation Methods

extension KeyAugmentationErrorInfoGeneric {
  /// For usage in subscript imps.
  public mutating func appendResolvingCollisions(augmentingIfNeededKey key: D.Key,
                                          value: D.Value,
                                          omitEqualValue: Bool,
                                          suffixSeparator: D.Key,
                                          randomSuffix: @Sendable () -> NonEmpty<D.Key>) {
    ErrorInfoDictFuncs.Merge._putAugmentingWithRandomSuffix(assumeModifiedKey: key,
                                                            value: value,
                                                            shouldOmitEqualValue: omitEqualValue,
                                                            suffixSeparator: suffixSeparator,
                                                            randomSuffix: randomSuffix,
                                                            to: &_dict)
  }
  
//  mutating func mergeWith(other: Self,
//                          donatorIndex: some BinaryInteger,
//                          omitEqualValue: Bool) {
//    for (keyValue) in other.storage {
//      ErrorInfoDictFuncs.Merge.withKeyAugmentationAdd(keyValue: keyValue,
//                                                      to: &storage,
//                                                      donatorIndex: donatorIndex,
//                                                      omitEqualValue: omitEqualValue,
//                                                      identity: ,
//                                                      suffixSeparator: ,
//                                                      randomSuffix: ,
//                                                      resolve: )
//    }
//  }
}

extension KeyAugmentationErrorInfoGeneric {
  public mutating func addKeyPrefix(_ keyPrefix: D.Key) {
    _dict = ErrorInfoDictFuncs.addKeyPrefix(keyPrefix, toKeysOf: _dict)
  }
}

// MARK: - Protocol Conformances

extension KeyAugmentationErrorInfoGeneric: Sendable where D: Sendable {}
