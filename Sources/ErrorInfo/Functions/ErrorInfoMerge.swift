//
//  ErrorInfo+Merge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

public enum ErrorInfoMerge: Namespacing {}

extension ErrorInfoMerge {}

public struct KeyCollisionResolvingInput<Key: Hashable, Value> {
  public let element: (key: Key, existingValue: Value, beingAddedValue: Value)
  public let areValuesApproximatelyEqual: Bool
  public let donatorIndex: any (BinaryInteger & CustomStringConvertible)
  public let fileLine: StaticFileLine
  
  public init(element: (key: Key, existingValue: Value, beingAddedValue: Value),
              areValuesApproximatelyEqual: Bool,
              donatorIndex: any BinaryInteger & CustomStringConvertible,
              fileLine: StaticFileLine) {
    self.element = element
    self.areValuesApproximatelyEqual = areValuesApproximatelyEqual
    self.donatorIndex = donatorIndex
    self.fileLine = fileLine
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
