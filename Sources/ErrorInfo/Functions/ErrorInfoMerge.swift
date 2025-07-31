//
//  ErrorInfo+Merge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 26/07/2025.
//

public enum ErrorInfoMerge: Namespacing {}

extension ErrorInfoMerge {}

struct KeyCollisionResolvingInput<Key, Value> {
  let donatorElement: (key: Key, value: Value)
  let recipientElement: (key: Key, value: Value)
  let fileLine: StaticFileLine?
}

public enum KeyCollisionResolvingResult {
  case modifyDonatorKey(_ modifiedDonatorKey: String)
  case modifyRecipientKey(_ modifiedRecipientKey: String)
  case modifyBothKeys(donatorKey: String, recipientKey: String)
}

public struct KeyCollisionResolve<D> where D: DictionaryUnifyingProtocol {
  private let body: (_ donator: D.Element, _ recipient: D.Element) -> KeyCollisionResolvingResult
  
  init(body: @Sendable @escaping (_: D.Element, _: D.Element) -> KeyCollisionResolvingResult) {
    self.body = body
  }
  
  public func callAsFunction(donatorElement: D.Element, recipientElement: D.Element)
    -> KeyCollisionResolvingResult {
      body(donatorElement, recipientElement)
  }
}

func res(res: KeyCollisionResolve<[String: Any]>) {
  res(donatorElement: ("", 5), recipientElement: ("", ""))
}
