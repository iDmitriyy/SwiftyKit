//
//  InformativeError.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

public protocol InformativeError: Error {
  associatedtype ErrorInfoType: ErrorInfoCollection
  
  var info: ErrorInfoType { get }
}

// TODO: shpuld Dictionary<K, V> or (any DictionaryUnifyingProtocol) conform to ErrorInfoCollection?
// If yes, it would be possible to compose and ErrorInfo with dicts and allows dicts merge-operations.

// This require some kind of interpolation like String(describing:), String(reflection:) and others

/*
 let dictA: [String: Any] = ...
 
 errorInfo.merging(with: dictA, interpolation: .description | .debugDescription)
 
 */
