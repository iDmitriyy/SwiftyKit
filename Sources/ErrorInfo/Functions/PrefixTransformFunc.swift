//
//  PrefixTransformFunc.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16/09/2025.
//

import IndependentDeclarations
import StdLibExtensions

public struct PrefixTransformFunc: Sendable {
  public typealias TransformFunc = @Sendable (_ key: String, _ prefix: String) -> String
  
  private let body: TransformFunc
  
  /// identity for debug purposes, .left – name, .right - file & line
  private let _identity: Either<String, StaticFileLine>
  
  public init(body: @escaping TransformFunc, fileLine: StaticFileLine = .this()) {
    self.body = body
    _identity = .right(fileLine)
  }
  
  public init(body: @escaping TransformFunc, identifier: String) {
    self.body = body
    _identity = .left(identifier)
  }
  
  internal func callAsFunction(key: String, prefix: String) -> String {
    body(key, prefix)
  }
}

extension PrefixTransformFunc {
  public static let concatenation =
    PrefixTransformFunc(body: { key, prefix in prefix + key },
                        identifier: "concatenation prefix + key")
  
  public static let concatenationUppercasingKeyFirstChar =
    PrefixTransformFunc(body: { key, prefix in prefix + key.uppercasingFirstLetter() },
                        identifier: "concatenation prefix + key.uppercasingFirstLetter()")
}

// MARK: - Composite Transform

// FIXME: - to do implementation
public struct PrefixCompositeTransformFunc: Sendable {
  public typealias TransformFunc = @Sendable (_ key: String, _ prefix: String) -> String
  
  private let funcs: [TransformFunc]
  
  private let _identity: Either<String, StaticFileLine>
  
  public init(funcs: [TransformFunc], fileLine: StaticFileLine = .this()) {
    self.funcs = funcs
    _identity = .right(fileLine)
  }
  
  public init(funcs: [TransformFunc], identifier: String) {
    self.funcs = funcs
    _identity = .left(identifier)
  }
}

/*
 Usage:
 
 merge(transformKey: .prependWith(prefix), .prependWith("_"), .uppercaseFirst)
 or
 merge(transformKey: { $0.uppercaseFirst.prependWith("prefix", "_") })
 
 firstly all transformations are applied for each key and then final result after all transformations is used as a key
 So collisions are resolved for final result of key transformations (not to intermediate results)
 
 // ?? how to convert different key styles?
 */
