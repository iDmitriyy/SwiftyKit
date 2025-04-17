//
//  ErrorInfoKeysTransform.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

extension ErronInfoKey {
  public func camelCased() -> Self {
    Self(Self.fromAnyStyleToCamelCased(string: string))
  }
  
  public func pascalCased() -> String {
    fatalError()
  }
  
  public func snakeCased() -> String {
    fatalError()
  }
  
  public func kebabCased() -> String {
    fatalError()
  }
}

extension ErrorInfoProtocol {
  public func camelCasingKeys() -> String {
    fatalError()
  }
  
  public func pascalCasingKeys() -> String {
    fatalError()
  }
  
  public func snakeCasingKeys() -> String {
    fatalError()
  }
  
  public func kebabCasingKeys() -> String {
    fatalError()
  }
}

extension DictionaryUnifyingRootProtocol {}

extension ErronInfoKey {
  internal static func fromAnyStyleToCamelCased(string: String) -> String {
    toPascalOrCamel(string: string, firstCharTransform: { $0.lowercased() })
  }
  
  internal static func fromAnyStyleToPascalCased(string: String) -> String {
    toPascalOrCamel(string: string, firstCharTransform: { $0.uppercased() })
  }
  
  private static func toPascalOrCamel(string: String, firstCharTransform: (Character) -> String) -> String {
    var result = ""
    var normalCharsCount: UInt = 0
    var previousWasSeprator = false
    for character in string {
      if character == "_" {
        previousWasSeprator = true
      } else if character == "-" {
        previousWasSeprator = true
      } else { // normal (non-separator) character:
        // TODO: If no transform was made, then self can be returned without making a copy to result.
        // save a flag to remeber if any trnasforms were made, save only current index and make actual transform
        // and result allocation only when trasform really needed.
        // Если после сепаратора то uppercased
        if normalCharsCount > 0 {
          if previousWasSeprator {
            result.append(character.uppercased())
          } else {
            result.append(character)
          }
        } else {
          result.append(firstCharTransform(character))
        }
        
        normalCharsCount += 1
        previousWasSeprator = false
      } // end if
    } // end for
    return normalCharsCount > 0 ? result : string
  }
  
  internal static func fromAnyStyleToSnakeCased(string: String) -> String {
    toSnakeOrKebab(string: string, separator: "_")
  }
  
  internal static func fromAnyStyleToKebabCased(string: String) -> String {
    toSnakeOrKebab(string: string, separator: "-")
  }
  
  private static func toSnakeOrKebab(string: String, separator: Character) -> String {
    enum PreviousCharState {
      case uppercase
      case lowercase
      case separator
    }
    var previousKind: PreviousCharState?
    var result = ""
    var normalCharsCount: UInt = 0
//    var previousWasUppercase = true // true to not add separator before first capitalized, e.g. Pascal | _pascal
//    var previousWasSparator = false
    for character in string {
      if character == "_" {
        result.append(separator)
        previousKind = .separator
      } else if character == "-" {
        result.append(separator)
        previousKind = .separator
      } else { // normal (non-separator) character:
        if character.isUppercase {
          if let previousKind, !(previousKind == .separator) && !(previousKind == .uppercase) {
            result.append(separator) // append separator for first Capitalised char
          }
          previousKind = .uppercase
        } else {
          previousKind = .lowercase
        }
        result.append(character.lowercased())
        normalCharsCount += 1
      } // end if
    } // end for
    return normalCharsCount > 0 ? result : String(repeating: separator, count: string.count)
  }
  
//  private static func toSnakeOrKebab(string: String, separator: Character) -> String {
//    var result = ""
//    var normalCharsCount: UInt = 0
//    var previousWasUppercase = true
//    for character in string {
//      if character == "_" {
//        result.append(separator)
//        previousWasUppercase = false
//      } else if character == "-" {
//        result.append(separator)
//        previousWasUppercase = false
//      } else { // normal (non-separator) character:
//        if character.isUppercase {
//          if previousWasUppercase {
//            ()
//          } else {
//            result.append(separator)
//          }
//          previousWasUppercase = true
//        } else {
//          previousWasUppercase = false
//        }
//        result.append(character.lowercased())
//        normalCharsCount += 1
//      } // end if
//    } // end for
//    return normalCharsCount > 0 ? result : String(repeating: separator, count: string.count)
//  }
}
