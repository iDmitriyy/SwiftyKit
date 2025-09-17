//
//  KeyAugmentationStrategy+AsDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 17/09/2025.
//

extension ErrorInfoUniqueKeysAugmentationStrategy where Self: ErrorInfoPartialCollection {
  public func asGenericDict<D>() -> D where D: DictionaryUnifyingProtocol<Key, Value> {
    var recipient = D(minimumCapacity: self.count)
    
    for (key, value) in self.keyValuesView {
      // TODO: crashing the app seems not be a good solution.
      // can it be statically proven? If not, how logging can be added?
      // finally, check that crash (not)happens if invariant is (not)violated
      precondition(!recipient.hasValue(forKey: key), "")
      recipient[key] = value
    }
    
    return recipient
  }
}
