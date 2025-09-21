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

import NonEmpty
import OrderedCollections

// base-error summary
func _merge(_ infos: NonEmptyArray<(any Error, info: [String: Any])>) {
  // JM4 ["decodingDate": date0, // collide with ME14
  //      "T.Type": type0, // collide with NE2
  //      "id": 0, // collide with ME14 & NE2
  //      "uid" 9, // collide with ME14 & NE2, but value is equal with ME14
  //      "jm":  "jm"]
  // ME14 ["decodingDate": date1,
  //       "timeStamp": time0, // collide with NE2
  //       "id": 1,
  //       "uid" 9,
  //       "me": "me"]
  // NE2 ["T.Type": type1,
  //      "timeStamp": time1,
  //      "id": 2,
  //      "uid" 0,
  //      "ne": "ne"]
  // =>
  // [
  //   "decodingDate_JM4": date0
  //   "T.Type_JM4": type0
  //   "id_JM4": 0
  //   "jm": "jm"
  //   "decodingDate_ME14": date1
  //   "timeStamp_ME14": time0
  //   "id_ME14": 1
  //   "me": "me"
  //   "T.Type_NE2": type1
  //   "timeStamp_NE2": time1
  //   "id_NE2": 2
  //   "ne": "ne"
  // ]
  typealias ErrorIdentity = Int // index
  var accumulator: [[String: Any]] = []
    
  
//  let dd = do {
//    54
//  }
//   @_noImplicitCopy let value = [5]
//   var d = value
  // - find all key intersections
  // - make memory about: errors at which indices have collisions for concrete key
  // - not collided keys are added to summary as is
  // - collided keys are augmented and added to summary
  
//  for (index, (_, info)) in infos.enumerated() { // !! three nested loops
//    let others = infos[(index + 1)...]
//
//    for others in others {
//      for (key, value) in info {
//
//      }
//    }
//  }
  
  struct Accumulator {
    var rest: Array<(any Error, info: [String: Any])>.SubSequence
    var collisions: [String: NonEmpty<OrderedSet<Int>>]
  }
  
  infos.reduce(into: Accumulator(rest: infos.rawValue[...], collisions: [:])) { partialResult, arg1 in
    let (_, info) = arg1
    partialResult.rest = partialResult.rest[(partialResult.rest.startIndex + 1)...]
    
    guard !partialResult.rest.isEmpty else { return }
    
    let keys = Set(info.keys)
    
    for (_, otherOnfo) in partialResult.rest {
      let otherKeys = Set(otherOnfo.keys)
      
      let intersection = keys.intersection(otherKeys)
      if !intersection.isEmpty {
        // save currentIndex & otherIndex
        let currentIndex = 0
        let otherIndex = 1
        
        for key in intersection {
          if var indexSet = partialResult.collisions[key] {
            // indexSet.insert(otherIndex) // only otherIndex
          } else {
            // let indexSet = NonEmpty<OrderedSet<Int>>(currentIndex, otherIndex)
            // partialResult.collisions[key] = indexSet
          }
        }
      }
    } // end for _ in partialResult.rest
  }
}
