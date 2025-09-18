//
//  ErrorInfoDictFuncs.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

private import StdLibExtensions

public enum ErrorInfoDictFuncs: Namespacing {}

// MARK: Add Key Prefix

extension ErrorInfoDictFuncs {
  public static func addKeyPrefix<V, Dict>(_ keyPrefix: String,
                                           toKeysOf dict: inout Dict,
                                           transform: PrefixTransformFunc)
    where Dict: DictionaryUnifyingProtocol<String, V> {
    var prefixedKeysDict = Dict(minimumCapacity: dict.count)
    
    // Adding prefix is similar to merge operation, except that key collisions can happen between own keys after they are transformed.
    // The are no donators, so use lower level soubroutine.
    // Example:
    // ["a": 1, "A": 2]
    // - Add a prefix == "product", with uppercasingKeyFirstChar
    // - key "a" will be uppercased which introduces a collision
    // After colissions resolving:
    // ["productA": 1, "productA#pL4A": 2]
    
    // While appearing of equal values making a merge is expected, such situation is not normal when adding a prefix
    // to all keys.
    // such self-collisions are something unexpected, so keep all values (shouldOmitEqualValue = false) in this case
    for (key, value) in dict {
      let prefixedKey = transform(key: key, prefix: keyPrefix)
      Merge._putResolvingWithRandomSuffix(value,
                                          assumeModifiedKey: prefixedKey,
                                          shouldOmitEqualValue: false,
                                          suffixFirstChar: ErrorInfoMerge.suffixBeginningForMergeScalar,
                                          to: &prefixedKeysDict)
    }
    return dict = prefixedKeysDict
  }
}
