//
//  ErrorInfoDictMerge.swift
//  swifty-kit
//
//  Created by tmp on 31/07/2025.
//

extension ErrorInfoDictFuncs {
  public enum Merge: Namespacing {}
}

extension ErrorInfoDictFuncs.Merge {
  // MARK: Dictionary

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
                                   otherSuffix: { "_r" + ErrorInfoFuncs.randomSuffix() },
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
      guard !ErrorInfoFuncs.isApproximatelyEqual(value, existingValue) else {
        return // если значения равны, оставляем в userInfo то которое уже в нём есть
      }
      
      // Возникновение коллизий маловероятно. Если оно всё же произошло, добавляем index
      // чтобы понять на каком участке цепочки возникла коллизия.
      // Например, если в 2х словарях возникла коллизия по ключу "decodingDate", получится такой порядок модификации ключа:
      // decodingDate ->
      let suffix = firstSuffix() // "decodingDate^line_81_idx1"
      var modifiedKey = key + suffix
      while let existingValue2 = errorInfo[modifiedKey] {
        if ErrorInfoFuncs.isApproximatelyEqual(value, existingValue2) {
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

  
  
  /// -----------------------------------------------------------------
  
  
  /// Key-modifying resloving collision
  static func merge<V, Dict>(_ donator: Dict,
                             to recipient: inout Dict,
                             file: StaticString? = nil,
                             line: (some BinaryInteger & CustomStringConvertible)? = nil,
                             omitEqualValue: Bool = true,
                             resolvingCollision: (_ a: Dict.Element, _ b: Dict.Element) -> KeyCollisionResolvingResult)
  -> ErrorInfo where Dict: DictionaryUnifyingProtocol<String, V> {
    for (key, value) in donator {
      if let existingValue = recipient[key] {
        if ErrorInfoFuncs.isApproximatelyEqual(value, existingValue) {
          
        } else {
          
        }
      } else {
        
      }
    }
    
    return .empty
  }
  
  static func merge<V, Dict>(_ donator: Dict,
                             to recipient: inout Dict,
                             omitEqualValue: Bool = true,
                             resolvingCollision: (_ a: Dict.Element, _ b: Dict.Element) -> KeyCollisionResolvingResult)
  -> ErrorInfo where Dict: DictionaryUnifyingProtocol<String, V> {
    for (key, value) in donator {
      if let existingValue = recipient[key] {
        if ErrorInfoFuncs.isApproximatelyEqual(value, existingValue) {
          
        } else {
          
        }
      } else {
        
      }
    }
    
    return .empty
  }
  
  // all merge functions have no default for omitEqualValue. Extension can be be made on user side, providing overload
  // with suitable default choice.
  
  static func _withResolvingCollisionsAdd<Dict>(keyValue: Dict.Element,
                                                to recipient: inout Dict,
                                                omitEqualValue shouldOmitEqualValue: Bool,
                                                resolvingResult: KeyCollisionResolvingResult) where Dict: DictionaryUnifyingProtocol {
    let (key, value) = keyValue
    if let existingValue = recipient[key] {
      guard !ErrorInfoFuncs.isApproximatelyEqual(value, existingValue) else {
        return // если значения равны, оставляем в userInfo то которое уже в нём есть
      }
      // if collision happened, but values are equal, then we can keep existing value
      if ErrorInfoFuncs.isApproximatelyEqual(value, existingValue) {
        if shouldOmitEqualValue {
          ()
        } else {
          
        }
      } else { // resolving must be done
        
      }
      
      let valuesAreEqual = ErrorInfoFuncs.isApproximatelyEqual(value, existingValue)
      switch (valuesAreEqual, shouldOmitEqualValue) {
      case (false, _): break // always keep different values, modify 1 or 2 keys
      case (true, true): break // omit
      case (true, false): break // keep both equal values, modify 1 or 2 keys
      }
      
      if ErrorInfoFuncs.isApproximatelyEqual(value, existingValue) {
        
      }
      
      // Например, если в 2х словарях возникла коллизия по ключу "decodingDate", получится такой порядок модификации ключа:
      // decodingDate ->
//      let suffix = firstSuffix() // "decodingDate^line_81_idx1"
//      var modifiedKey = key + suffix
//      while let existingValue2 = errorInfo[modifiedKey] {
//        if ErrorInfoFuncs.isApproximatelyEqual(value, existingValue2) {
//          return
//        } else {
//          modifiedKey += otherSuffix() // "decodingDate^line_81_idx1_1"
//        }
//      }
      
//      errorInfo[modifiedKey] = value
    } else { // if no collisions then add to recipient
      recipient[key] = value
    }
  }
  
  
}


