//
//  KeyAugmentationStrategy+AsDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 17/09/2025.
//

extension ErrorInfoUniqueKeysAugmentationStrategy where Self: ErrorInfoPartialCollection {
  public func asDictGeneric<D>() -> D where D: DictionaryUnifyingProtocol<Key, Value> {
    var recipient = D(minimumCapacity: count)
    
    let keyVaues = keyValuesView
    var keyVauesCount: Int = 0
    for (key, value) in keyVaues {
      // TODO: crashing the app by precondition seems not be a good solution.
      // can it be statically proven? If not, how logging can be added?
      // finally, check that crash (not)happens if invariant is (not)violated
      
      recipient[key] = value
      keyVauesCount += 1
    }
    // keyVaues must contain unique keys (when get from ErrorInfo with UniqueKeysAugmentationStrategy)
    precondition(recipient.count == keyVauesCount)
    
    return recipient
  }
}
