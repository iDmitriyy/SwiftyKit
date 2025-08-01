//
//  ErrorInfoDictFuncs.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

private import StdLibExtensions

public enum ErrorInfoDictFuncs: Namespacing {}

extension ErrorInfoDictFuncs {
  // MARK: Add Key Prefix

  public static func addKeyPrefix<V, Dict>(_ keyPrefix: String,
                                           toKeysOf dict: Dict,
                                           uppercasingFirstLetter: Bool = true,
                                           line _: UInt = #line) -> Dict where Dict: DictionaryUnifyingProtocol<String, V> {
    var prefixedKeysDict = Dict(minimumCapacity: dict.count)
    
    for (key, value) in dict {
      // Edge Case:
      // ["a": 1, "A": 2]
      // after adding `prefix` with uppercasingFirstLetter:
      // ["prefixA": 1, "prefixA^line_81_BF3": 2]
      let prefixedKey = keyPrefix + (uppercasingFirstLetter ? key.uppercasingFirstLetter() : key)
      //    _addResolvingKeyCollisions(key: prefixedKey,
      //                               value: value,
      //                               firstSuffix: { "^line_\(line)_r" + BaseErrorImpFunctions.randomSuffix() },
      //                               otherSuffix: BaseErrorImpFunctions.randomSuffix,
      //                               to: &prefixedKeysDict)
      fatalError()
    }
    
    return prefixedKeysDict
  }
}
