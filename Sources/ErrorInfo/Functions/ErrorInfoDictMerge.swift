//
//  ErrorInfoDictMerge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

import StdLibExtensions

extension ErrorInfoDictFuncs {
  public enum Merge: Namespacing {}
}

/// all merge functions have no default value for omitEqualValue arg.
/// Extension can be be made on user side, providing overload with suitable default choice.
extension ErrorInfoDictFuncs.Merge {
  // MARK: Merge
  
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
  internal static func _mergeErrorInfo<V, C>(_ recipient: inout some DictionaryUnifyingProtocol<String, V>,
                                          with donators: [some DictionaryUnifyingProtocol<String, V>],
                                          omitEqualValue: Bool,
                                          identity: C = StaticFileLine.this(),
                                          resolve: (ResolvingInput<String, V, C>) -> ResolvingResult<String>) {
    for (donatorIndex, donator) in donators.enumerated() {
      for donatorElement in donator {
        withResolvingCollisionsAdd(keyValue: donatorElement,
                                   to: &recipient,
                                   donatorIndex: donatorIndex,
                                   omitEqualValue: omitEqualValue,
                                   identity: identity,
                                   resolve: resolve)
      } // end for (key, value)
    } // end for (index, otherInfo)
  }
  
//   repeat (each Dict).Key == String  Not supported by Swift yet, wait for some swift 6.x > 6.2
//  internal static func _mergeErrorInfo<V, each Dict>(_ recipient: inout some DictionaryUnifyingProtocol<String, V>,
//                                          with donators: repeat each Dict,
//                                          omitEqualValue: Bool,
//                                          fileLine: StaticFileLine,
//                                          resolve: (ResolvingInput<String, V>) -> ResolvingResult<String>)
//  where repeat each Dict: DictionaryUnifyingProtocol, repeat (each Dict).Key == String {
//    for donator in repeat each donators {
//      for donatorElement in donator {
//        withResolvingCollisionsAdd(keyValue: donatorElement,
//                                   to: &recipient,
//                                   donatorIndex: donatorIndex,
//                                   omitEqualValue: omitEqualValue,
//                                   fileLine: fileLine,
//                                   resolve: resolve)
//      } // end for (key, value)
//    } // end for (index, otherInfo)
//  }
}

// MARK: - Low level root functions for  a single value 

extension ErrorInfoDictFuncs.Merge {
  public typealias ResolvingInput<Key: Hashable, Value, C> = KeyCollisionResolvingInput<Key, Value, C>
  public typealias ResolvingResult<Key: Hashable> = KeyCollisionResolvingResult<Key>
  
  /// Add value by key to recipient` dictionary`.
  /// For key-value pair, the function checks if the key already exists in the `recipient` dictionary.
  /// If the key does not already contained in the `recipient` dictionary, the function simply adds this key-value pair to the `recipient` dictionary.
  /// If it is contained, the function checks if the value is approximately equal to the existing value in the `recipient` dictionary.
  /// If they are approximately equal, then the function leaves in the dictionary the value that is already there
  /// If not, then the function modifies the key by appending a generated suffix consisting of the current line number and the `index`.
  /// The function then checks if the modified key already exists in the errorInfo dictionary.
  /// If it does, it appends the index of the current dictionary to the suffix and checks again until it finds a key that does not exist in the `errorInfo` dictionary.
  /// Once a unique key is finally created (typically it happens from first time), the function adds the key-value pair to the `recipient` dictionary.
  /// - Parameters:
  ///   - donatorKeyValue:
  ///   - recipient:
  ///   - donatorIndex:
  ///   - shouldOmitEqualValue:
  ///   - identity:
  ///   - resolve:
  public static func withResolvingCollisionsAdd<Dict, C>(keyValue donatorKeyValue: Dict.Element,
                                                         to recipient: inout Dict,
                                                         donatorIndex: some BinaryInteger & CustomStringConvertible,
                                                         omitEqualValue shouldOmitEqualValue: Bool,
                                                         identity: C,
                                                         resolve: (ResolvingInput<Dict.Key, Dict.Value, C>) -> ResolvingResult<Dict.Key>)
  where Dict: DictionaryUnifyingProtocol, Dict.Key == String {
    // TODO: update func documentation
    let (donatorKey, donatorValue) = donatorKeyValue
    // In, most cases value is simply added to recipient. When collision happens, it must be properly resolved.
    if let recipientValue = recipient[donatorKey] {
      let collidedKey = donatorKey
      // if collision happened, but values are equal, then we can keep existing value
      let valuesAreEqual = ErrorInfoFuncs.isApproximatelyEqualAny(recipientValue, donatorValue)
      
      typealias Input = KeyCollisionResolvingInput<Dict.Key, Dict.Value, C>
      let element = Input.Element(key: collidedKey,
                                  existingValue: recipientValue,
                                  beingAddedValue: donatorValue)
      lazy var resolvingInput = Input(element: element,
                                      areValuesApproximatelyEqual: valuesAreEqual,
                                      donatorIndex: donatorIndex,
                                      identity: identity)
      
      let resolvingResult: KeyCollisionResolvingResult<Dict.Key>
      switch (valuesAreEqual, shouldOmitEqualValue) {
      case (true, true): return // if newly added value is equal to current, then keep only existing
      case (false, _), // different values must be saved, modify one of or both keys
           (true, false): // keep both values though they are equal, modify one of or both keys
        resolvingResult = resolve(resolvingInput)
      }
      
      let suffixFirstChar: UnicodeScalar = ErrorInfoMerge.suffixBeginningForMergeScalar
      switch resolvingResult {
      case let .modifyDonatorKey(assumeWasModifiedDonatorKey):
        _putResolvingWithRandomSuffix(donatorValue,
                                      assumeModifiedKey: assumeWasModifiedDonatorKey,
                                      shouldOmitEqualValue: shouldOmitEqualValue,
                                      suffixFirstChar: suffixFirstChar,
                                      to: &recipient)
        
      case let .modifyRecipientKey(assumeWasModifiedRecipientKey):
        // 1. replace value that was already contained in recipient by donatorValue
        recipient[collidedKey] = donatorValue
        // 2. put value that was already contained in recipient by modifiedRecipientKey
        _putResolvingWithRandomSuffix(recipientValue,
                                      assumeModifiedKey: assumeWasModifiedRecipientKey,
                                      shouldOmitEqualValue: shouldOmitEqualValue,
                                      suffixFirstChar: suffixFirstChar,
                                      to: &recipient)
        
      case let .modifyBothKeys(assumeWasModifiedDonatorKey, assumeWasModifiedRecipientKey):
        recipient[collidedKey] = nil // remove old key & value
        _putResolvingWithRandomSuffix(donatorValue,
                                      assumeModifiedKey: assumeWasModifiedDonatorKey,
                                      shouldOmitEqualValue: shouldOmitEqualValue,
                                      suffixFirstChar: suffixFirstChar,
                                      to: &recipient)
        
        _putResolvingWithRandomSuffix(recipientValue,
                                      assumeModifiedKey: assumeWasModifiedRecipientKey,
                                      shouldOmitEqualValue: shouldOmitEqualValue,
                                      suffixFirstChar: suffixFirstChar,
                                      to: &recipient)
      }
    } else { // if no collisions then add to recipient
      recipient[donatorKey] = donatorValue
    }
  }
  
//  private static func _makeInput<Dict>(collidedKey: String,
//                       recipientValue: Dict.Value,
//                        donatorValue: Dict.Value,
//                        valuesAreEqual: Bool,
//                        donatorIndex: some BinaryInteger & CustomStringConvertible,
//                        fileLine: StaticFileLine)
//    -> ResolvingInput<Dict.Key, Dict.Value> where Dict: DictionaryUnifyingProtocol, Dict.Key == String {
//      let element = KeyCollisionResolvingInput.Element(key: collidedKey,
//                                                       existingValue: recipientValue,
//                                                       beingAddedValue: donatorValue)
//      return KeyCollisionResolvingInput(element: element,
//                                                           areValuesApproximatelyEqual: valuesAreEqual,
//                                                           donatorIndex: donatorIndex,
//                                                           fileLine: fileLine)
//  }
  
  /// decomposition subroutine of func withResolvingCollisionsAdd()
  internal static func _putResolvingWithRandomSuffix<Dict>(_ value: Dict.Value,
                                                           assumeModifiedKey: Dict.Key,
                                                           shouldOmitEqualValue: Bool,
                                                           suffixFirstChar: UnicodeScalar,
                                                           to recipient: inout Dict)
    where Dict: DictionaryUnifyingProtocol, Dict.Key == String {
    // Here we can can only make an assumtption that donator key was modified on the client side.
    // While it should always happen, there is no guarantee.
    
    // So there are 2 possible collision variants here:
    // 1. assumeWasModifiedDonatorKey was not really modified
    // 2. assumeWasModifiedDonatorKey also has a collision with another existing key of recipient
    var modifiedKey = assumeModifiedKey
    var counter: Int = 0
    while let recipientAnotherValue = recipient[modifiedKey] { // condition mostly always should not happen
//      if Dict.Value.self == (any Equatable).Type.self {
//        // TODO: ...
//      }
      switch (ErrorInfoFuncs.isApproximatelyEqualAny(recipientAnotherValue, value), shouldOmitEqualValue) {
      case (true, true): return // if newly added value is equal to current, then keep only existing
      case (false, _), // ?? always keep different values
           (true, false): // ?? keep both equal values
        let randomSuffix = ErrorInfoFuncs.randomSuffix()
        let suffix = counter == 0 ? String(suffixFirstChar) + randomSuffix : randomSuffix
        modifiedKey += suffix
        counter += 1
        // example: 3 error-info instances with decodingDate key
        // "decodingDate_don0_file_line_SourceFileName_81_#9vT"
      }
    }
    recipient[modifiedKey] = value
  }
}
