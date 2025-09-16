//
//  ErrorInfo+Merge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

public enum ErrorInfoMerge: Namespacing {}

extension ErrorInfoMerge {
  /// "$"
  internal static let suffixBeginningForSubcriptAsciiCode: UInt8 = 36
  /// "$"
  internal static let suffixBeginningForSubcriptScalar = UnicodeScalar(suffixBeginningForSubcriptAsciiCode)
  
  /// "#"
  internal static let suffixBeginningForMergeAsciiCode: UInt8 = 35
  /// "#"
  internal static let suffixBeginningForMergeScalar = UnicodeScalar(suffixBeginningForMergeAsciiCode)
}

public struct KeyCollisionResolvingInput<Key: Hashable, Value, CId> {
  public let element: Element
  public let areValuesApproximatelyEqual: Bool
  public let donatorIndex: any (BinaryInteger & CustomStringConvertible)
  /// This can be `File + Line`, `Error domain + code` etc.
  public let identity: CId
  
  internal init(element: Element,
                areValuesApproximatelyEqual: Bool,
                donatorIndex: any BinaryInteger & CustomStringConvertible,
                identity: CId) {
    self.element = element
    self.areValuesApproximatelyEqual = areValuesApproximatelyEqual
    self.donatorIndex = donatorIndex
    self.identity = identity
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
