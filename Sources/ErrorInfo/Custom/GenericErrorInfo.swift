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
  
  func unconditionallyRemoveValue(forKey: Key) {}
  
  func mergeWith(other: Self) {}
}



extension _ErrorInfoGenericStorage: Equatable where Key: Equatable, Value: Equatable, DictType: Equatable {}
extension _ErrorInfoGenericStorage: Hashable where Key: Hashable, Value: Hashable, DictType: Hashable {}

extension _ErrorInfoGenericStorage: Sendable where Key: Sendable, Value: Sendable, DictType: Sendable {}

// --------------------------------------

struct _ErrorInfoGenericValue<ValueType> {
  
}


/// NoRemovingErrorInfo Is specially made for BaseError default merge algorythms.
/// As BaseError types can contain different error-info implementations, each instance can have different merge function.
typealias NoRemovingErrorInfo<V> = _ErrorInfoGenericValue<V>

/// BaseError `summaryErrorInfo` should return Opaque type.
/// Each error-info type should have an ability to initialize from another one, like collections can be initialized from each other.
