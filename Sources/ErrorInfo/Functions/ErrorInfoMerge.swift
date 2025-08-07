//
//  ErrorInfo+Merge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

public enum ErrorInfoMerge: Namespacing {}

extension ErrorInfoMerge {
  /// "$"
  internal static let suffixBeginningForSubcriptAscii: UInt8 = 36
  /// "$"
  internal static let suffixBeginningForSubcriptScalar = UnicodeScalar(suffixBeginningForSubcriptAscii)
  
  /// "#"
  internal static let suffixBeginningForMergeAscii: UInt8 = 35
  /// "#"
  internal static let suffixBeginningForMergeScalar = UnicodeScalar(suffixBeginningForMergeAscii)
}

public struct KeyCollisionResolvingInput<Key: Hashable, Value> {
  public let element: Element
  public let areValuesApproximatelyEqual: Bool
  public let donatorIndex: any (BinaryInteger & CustomStringConvertible)
  /// ?? fileLine: StaticFileLine should be abstracted as "Collision Identifier"
  public let fileLine: StaticFileLine
  
  internal init(element: Element,
                areValuesApproximatelyEqual: Bool,
                donatorIndex: any BinaryInteger & CustomStringConvertible,
                fileLine: StaticFileLine) {
    self.element = element
    self.areValuesApproximatelyEqual = areValuesApproximatelyEqual
    self.donatorIndex = donatorIndex
    self.fileLine = fileLine
  }
  
  public struct Element {
    public let key: Key
    public let existingValue: Value
    public let beingAddedValue: Value
    
    internal init(key: Key,
                  existingValue: Value,
                  beingAddedValue: Value) {
      self.key = key
      self.existingValue = existingValue
      self.beingAddedValue = beingAddedValue
    }
  }
}

public enum KeyCollisionResolvingResult<Key: Hashable> {
  case modifyDonatorKey(_ modifiedDonatorKey: Key)
  case modifyRecipientKey(_ modifiedRecipientKey: Key)
  case modifyBothKeys(donatorKey: Key, recipientKey: Key)
}

//public struct KeyCollisionResolve<D> where D: DictionaryUnifyingProtocol {
//  private let body: (_ donator: D.Element, _ recipient: D.Element) -> KeyCollisionResolvingResult
//  
//  init(body: @Sendable @escaping (_: D.Element, _: D.Element) -> KeyCollisionResolvingResult) {
//    self.body = body
//  }
//  
//  public func callAsFunction(donatorElement: D.Element, recipientElement: D.Element)
//    -> KeyCollisionResolvingResult {
//      body(donatorElement, recipientElement)
//  }
//}

//func res(res: KeyCollisionResolve<[String: Any]>) {
//  res(donatorElement: ("", 5), recipientElement: ("", ""))
//}

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
  
  public static let concatenation =
    PrefixTransformFunc(body: { key, prefix in prefix + key },
                        identifier: "concatenation prefix + key")
  
  public static let uppercasingKeyFirstChar =
    PrefixTransformFunc(body: { key, prefix in prefix + key.uppercasingFirstLetter() },
                        identifier: "concatenation prefix + key.uppercasingFirstLetter()")
}
