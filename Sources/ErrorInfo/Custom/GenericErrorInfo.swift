//
//  GenericErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

fileprivate struct _ErrorInfoGeneric<Key, Value, DictType: DictionaryUnifyingProtocol>
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

extension _ErrorInfoGeneric: Equatable where Key: Equatable, Value: Equatable, DictType: Equatable {}
extension _ErrorInfoGeneric: Hashable where Key: Hashable, Value: Hashable, DictType: Hashable {}

extension _ErrorInfoGeneric: Sendable where Key: Sendable, Value: Sendable, DictType: Sendable {}
