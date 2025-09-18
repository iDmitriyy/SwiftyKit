//
//  GenericErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

fileprivate struct _ErrorInfoGenericStorage<Key, Value, DictType: DictionaryUnifyingProtocol>
  where DictType.Key == Key, DictType.Value == Value {
  typealias ValueType = ErrorInfo.Value
  
  fileprivate private(set) var storage: DictType
  
  // TODO: - imp
  // - may be make current ErrorInfo ordedred & delete ErrorOrderedInfo.
//  public var _asStringDict: DictType { storage.mapValues { String(describing: $0) } }
  
  fileprivate init(storage: DictType) {
    self.storage = storage
  }
}

extension _ErrorInfoGenericStorage {
  func unconditionallyAddResolvingCollisions() {}
  
  func unconditionallyRemoveValue(forKey _: Key) {}
  
  func mergeWith(other _: Self) {}
}

// @inlinable public mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
// @inlinable public mutating func removeValue(forKey key: Key) -> Value?

extension _ErrorInfoGenericStorage: Sendable where Key: Sendable, Value: Sendable, DictType: Sendable {}

// --------------------------------------

struct _ErrorInfoGenericValue<ValueType> {}

/// NoRemovingErrorInfo Is specially made for BaseError default merge algorythms.
/// As BaseError types can contain different error-info implementations, each instance can have different merge function.
// typealias NoRemovingErrorInfo<V> = _ErrorInfoGenericValue<V>

/// BaseError `summaryErrorInfo` should return Opaque type.
/// Each error-info type should have an ability to initialize from another one, like collections can be initialized from each other.

import NonEmpty

struct KeyAugmentationErrorInfoGeneric<D>
  where D: DictionaryUnifyingProtocol, D.Key: RangeReplaceableCollection {
  
  private var storage: D
  
  init() {
    storage = D()
  }
  
  /// For usage in subscript imps.
  mutating func unconditionallyAdd(augmentingIfNeededKey key: D.Key,
                                   value: D.Value,
                                   omitEqualValue: Bool,
                                   suffixSeparator: D.Key,
                                   randomSuffix: @Sendable () -> NonEmpty<D.Key>) {
    ErrorInfoDictFuncs.Merge._putAugmentingWithRandomSuffix(value,
                                      assumeModifiedKey: key,
                                      shouldOmitEqualValue: omitEqualValue,
                                      suffixSeparator: suffixSeparator,
                                      randomSuffix: randomSuffix,
                                      to: &storage)
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
