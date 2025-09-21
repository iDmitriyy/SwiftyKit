//
//  Error+Merge.swift
//  swifty-kit
//
//  Created by tmp on 21/09/2025.
//

extension Error {
  public func mergedErrorInfo(with other: some Error,
                              omitEqualValue omitIfEqual: Bool = true,
//                                   keyType: Key.Type = String.self,
                              collisionSpecifier: some (CustomStringConvertible & Sendable) = StaticFileLine.this().asCollisionSpecifierString())
    -> [String: Any] {
    var recipient = (_userInfo as? [String: Any]) ?? [:] // as? [Key: Any]
    let donator = (other._userInfo as? [String: Any]) ?? [:]
    // FIXME: WIP
    ErrorInfoDictFuncs.Merge
      ._mergeErrorInfo(&recipient,
                       with: [donator],
                       omitEqualValue: omitIfEqual,
                       identity: collisionSpecifier,
                       resolve: { input in
                         let recipientKey = input.element.key + _domain + ".\(_code)"
                         let donatorKey = input.element.key + other._domain + ".\(other._code)"
                         if recipientKey != donatorKey {
                           return .modifyBothKeys(donatorKey: donatorKey, recipientKey: recipientKey)
                         } else {
                           let collisionSpecifier = String(describing: collisionSpecifier)
                           return .modifyBothKeys(donatorKey: donatorKey + "_d_" + collisionSpecifier,
                                                  recipientKey: recipientKey + "_r_" + collisionSpecifier)
                         }
                       })
    return recipient
  }
}

extension StaticFileLine {
  public func asCollisionSpecifierString() -> String {
    String(fileID) + ":\(line)"
  }
}
