//
//  MultiValueErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import OrderedCollections
import IndependentDeclarations

/// If a key collision happens, the values are put into a container
struct MultiValueErrorInfo {
  typealias Element = Either<any ErrorInfoType, [any ErrorInfoType]>
  
  public mutating func addKeyPrefix(_ keyPrefix: String, fileLine: StaticFileLine = .this()) {
    fatalError()
  }
  
  public mutating func merge<each D>(_ donators: repeat each D) where repeat each D: ErrorInfoCollection {
    fatalError()
  }
}
