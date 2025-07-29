//
//  ErrorInfoFunctions.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

public import protocol IndependentDeclarations.DictionaryUnifyingProtocol
private import FoundationExtensions

// MARK: - Merge ErrorInfo

public enum ErrorInfoFunctions: Namespacing {
  // MARK: Dictionary

  public static func mergeErrorInfo<V>(_ otherInfo: some DictionaryUnifyingProtocol<String, V>,
                                       to errorInfo: inout some DictionaryUnifyingProtocol<String, V>,
                                       addingKeyPrefix keyPrefix: String,
                                       uppercasingFirstLetter: Bool = true,
                                       line: UInt = #line) {
    let prefixedOtherInfo = addKeyPrefix(keyPrefix, toKeysOf: otherInfo, uppercasingFirstLetter: uppercasingFirstLetter, line: line)
    mergeErrorInfo(prefixedOtherInfo, to: &errorInfo, line: line)
  }

  public static func mergeErrorInfo<Dict, V>(_ otherInfos: Dict...,
                                             to errorInfo: inout some DictionaryUnifyingProtocol<String, V>,
                                             line: UInt = #line) where Dict: DictionaryUnifyingProtocol<String, V> {
    _mergeErrorInfo(&errorInfo, with: otherInfos, line: line)
  }

  public static func mergedErrorInfos<V, Dict>(_ errorInfo: Dict, _ otherInfos: Dict..., line: UInt = #line)
    -> Dict where Dict: DictionaryUnifyingProtocol<String, V> {
    var errorInfo = errorInfo
    _mergeErrorInfo(&errorInfo, with: otherInfos, line: line)
    return errorInfo
  }

  /// The purpose of this function is to merge multiple dictionaries of error information into a single dictionary, handling any key collisions by appending a unique suffix to the key.
  ///
  /// The function loops through each dictionary in the `otherInfos` array and for each dictionary, it loops through its key-value pairs.2
  /// For each key-value pair, the function checks if the key already exists in the `errorInfo` dictionary.
  /// If the key does not already contained in the `errorInfo` dictionary, the function simply adds this key-value pair to the `errorInfo` dictionary.
  /// If it is contained, the function checks if the value is approximately equal to the existing value in the `errorInfo` dictionary.
  /// If they are approximately equal, then the function leaves in the dictionary the value that is already there
  /// If not, then the function modifies the key by appending a generated suffix consisting of the current line number and the `index` of the current dictionary in the `otherInfos` array.
  /// The function then checks if the modified key already exists in the errorInfo dictionary.
  /// If it does, it appends the index of the current dictionary to the suffix and checks again until it finds a key that does not exist in the `errorInfo` dictionary.
  /// Once it finds a unique key, the function adds the key-value pair to the `errorInfo` dictionary.
  internal static func _mergeErrorInfo<V>(_ errorInfo: inout some DictionaryUnifyingProtocol<String, V>,
                                          with otherInfos: [some DictionaryUnifyingProtocol<String, V>],
                                          line: UInt) {
    for (index, otherInfo) in otherInfos.enumerated() {
      for (key, value) in otherInfo {
        _addResolvingKeyCollisions(key: key,
                                   value: value,
                                   firstSuffix: { "^line_\(line)_idx\(index)" },
                                   otherSuffix: { "_r" + ErrorInfoFunctions.randomSuffix() },
                                   to: &errorInfo)
      } // end for (key, value)
    } // end for (index, otherInfo)
  }

  /// For key-value pair, the function checks if the key already exists in the `errorInfo` dictionary.
  /// If the key does not already contained in the `errorInfo` dictionary, the function simply adds this key-value pair to the `errorInfo` dictionary.
  /// If it is contained, the function checks if the value is approximately equal to the existing value in the `errorInfo` dictionary.
  /// If they are approximately equal, then the function leaves in the dictionary the value that is already there
  /// If not, then the function modifies the key by appending a generated suffix consisting of the current line number and the `index`.
  /// The function then checks if the modified key already exists in the errorInfo dictionary.
  /// If it does, it appends the index of the current dictionary to the suffix and checks again until it finds a key that does not exist in the `errorInfo` dictionary.
  /// Once it finds a unique key, the function adds the key-value pair to the `errorInfo` dictionary.
  internal static func _addResolvingKeyCollisions<V>(key: String,
                                                     value: V,
                                                     firstSuffix: () -> String,
                                                     otherSuffix: () -> String,
                                                     to errorInfo: inout some DictionaryUnifyingProtocol<String, V>) {
    if let existingValue = errorInfo[key] {
      guard !ErrorInfoFunctions.isApproximatelyEqual(value, existingValue) else {
        return // если значения равны, оставляем в userInfo то которое уже в нём есть
      }
      
      // Возникновение коллизий маловероятно. Если оно всё же произошло, добавляем index
      // чтобы понять на каком участке цепочки возникла коллизия.
      // Например, если в 2х словарях возникла коллизия по ключу "decodingDate", получится такой порядок модификации ключа:
      // decodingDate ->
      let suffix = firstSuffix() // "decodingDate^line_81_idx1"
      var modifiedKey = key + suffix
      while let existingValue2 = errorInfo[modifiedKey] {
        if ErrorInfoFunctions.isApproximatelyEqual(value, existingValue2) {
          return
        } else {
          modifiedKey += otherSuffix() // "decodingDate^line_81_idx1_1"
        }
      }
      
      errorInfo[modifiedKey] = value
    } else { // если коллизии отсутствуют – кладём в словарь
      errorInfo[key] = value
    }
  }

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
