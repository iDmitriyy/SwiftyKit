//
//  ErrorInfoSubSequence.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16/09/2025.
//

protocol ErrorInfoSubSequenceProvidaeble<Key, ValueType> where Key: Hashable {
  associatedtype Key
  associatedtype ValueType
  
  typealias Element = (key: Key, value: ValueType)
  
  associatedtype Subsequnce: Sequence where Subsequnce.Element == Element
}
