//
//  ErrorInfo+AsDictionary.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 17/09/2025.
//

// MARK: Default implementations

// TODO: need to be generalized for Integer types >= UInt32

// MARK: Conversion MultipleValues => Dictionary (Key Augmentation)

extension ErrorInfoMultipleValuesForKeyStrategy where Self: ErrorInfoPartialCollection, Key == String {
//  func asStringDict<I>(omitEqualValue: Bool,
//                       identity: I,
//                       resolve: (ResolvingInput<String, V, C>) -> ResolvingResult<String>) -> [String: String] {
//  }
  
//  @specialized(where Dict == DictionaryUnifyingProtocol<String, any ErrorInfoValueType>)
//  @specialized(where Key == String, Value == String, I == String)
//  @_specialize(where I == String, D == Dictionary<String, String>)
//  @_specialize(where Key == String, Value == String)
  /// Key-augmentation merge strategy.
  func asGenericDict<I, D>(omitEqualValue: Bool,
                           identity: I,
                           resolve: (KeyCollisionResolvingInput<Key, Value, I>) -> KeyCollisionResolvingResult<Key>)
    -> D where D: DictionaryUnifyingProtocol<Key, Value> {
    var recipient = D(minimumCapacity: count)
    
    for keyValue in keyValuesView {
      ErrorInfoDictFuncs.Merge.withKeyAugmentationAdd(keyValue: keyValue,
                                                      to: &recipient,
                                                      donatorIndex: 0,
                                                      omitEqualValue: omitEqualValue,
                                                      identity: identity,
                                                      resolve: resolve)
    }
    
    return recipient
  }
}

// TODO: add generic imp when !(Key == String)

// MARK: Conversion MultipleValues => Dictionary (Array of values)

import OrderedCollections
public import NonEmpty

extension ErrorInfoMultipleValuesForKeyStrategy where Self: ErrorInfoPartialCollection {
  // ExpressibleByArrayLiteral – is only need for some kind of initialization. Somethong like `minimumCapacityInitializable`
  // can also be used.
  public func asMultipleValuesGenericDict<D, VC>(omitEqualValue _: Bool) -> D
    where D: DictionaryUnifyingProtocol<Key, NonEmpty<VC>>, VC: RangeReplaceableCollection, VC.Element == Self.Value {
    // VC: ExpressibleByArrayLiteral, VC.ArrayLiteralElement == Self.Value
    var dict: D = D(minimumCapacity: count)
    // VC: RangeReplaceableCollection –
    // init()
    // init(repeating repeatedValue: Self.Element, count: Int)
    // init<S>(_ elements: S) where S : Sequence, Self.Element == S.Element
    // mutating func reserveCapacity(_ n: Int)
    for (key, value) in keyValuesView {
      if dict.hasValue(forKey: key) {
        dict[key]?.append(value)
      } else {
        var wrappedValue = VC()
        wrappedValue.append(value)
        dict[key] = NonEmpty<VC>(rawValue: wrappedValue)
      }
    }
    return dict
  }
  
  // Fully opaque type is impossible yet
  // func asMultipleValuesDict(omitEqualValue: Bool) -> some DictionaryUnifyingProtocol<Key, NonEmpty<some Collection<Value>>>
  
  func asMultipleValuesOpaqueDict(omitEqualValue: Bool) -> some DictionaryUnifyingProtocol<Key, NonEmptyArray<Value>> {
    imp_asMultipleValuesDict(omitEqualValue: omitEqualValue)
  }
  
  func asMultipleValuesOpaqueDict(omitEqualValue: Bool) -> OrderedDictionary<Key, NonEmpty<some Collection<Value>>> {
    imp_asMultipleValuesDict(omitEqualValue: omitEqualValue)
  }
  
  private func imp_asMultipleValuesDict(omitEqualValue: Bool) -> OrderedDictionary<Key, NonEmptyArray<Value>> {
    asMultipleValuesGenericDict(omitEqualValue: omitEqualValue)
//    var dict: OrderedDictionary<Key, [Value]> = [:]
//    for (key, value) in self.keyValuesView {
//      if dict.hasValue(forKey: key) {
//        dict[key]?.append(value)
//      } else {
//        dict[key] = [value]
//      }
//    }
//    return dict
  }
}
