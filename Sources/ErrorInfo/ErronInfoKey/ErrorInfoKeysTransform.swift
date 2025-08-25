//
//  ErrorInfoKeysTransform.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

//extension ErronInfoKey {
//  public func camelCased() -> Self {
//    Self(uncheckedString: Self.fromAnyStyleToCamelCased(string: rawValue))
//  }
//  
//  public func pascalCased() -> Self {
//    Self(uncheckedString: Self.fromAnyStyleToPascalCased(string: rawValue))
//  }
//  
//  public func snakeCased() -> Self {
//    Self(uncheckedString: Self.fromAnyStyleToSnakeCased(string: rawValue))
//  }
//  
//  public func kebabCased() -> Self {
//    Self(uncheckedString: Self.fromAnyStyleToKebabCased(string: rawValue))
//  }
//}

// extension ErrorInfoProtocol {
//  public func camelCasingKeys() -> String {
//    fatalError()
//  }
//
//  public func pascalCasingKeys() -> String {
//    fatalError()
//  }
//
//  public func snakeCasingKeys() -> String {
//    fatalError()
//  }
//
//  public func kebabCasingKeys() -> String {
//    fatalError()
//  }
// }

//extension DictionaryUnifyingRootProtocol {} // make static method to ErrorInfo for converting Dict?

extension ErronInfoKey {
  internal static func fromAnyStyleToCamelCased(string: String) -> String {
    _toPascalOrCamelImp(string: string, firstCharTransform: { $0.lowercased() })
  }
  
  internal static func fromAnyStyleToPascalCased(string: String) -> String {
    _toPascalOrCamelImp(string: string, firstCharTransform: { $0.uppercased() })
  }
  
  internal static func fromAnyStyleToSnakeCased(string: String) -> String {
    _toSnakeOrKebabImp(string: string, separator: "_")
  }
  
  internal static func fromAnyStyleToKebabCased(string: String) -> String {
    _toSnakeOrKebabImp(string: string, separator: "-")
  }
}

extension ErronInfoKey {
  private static func _toPascalOrCamelImp(string: String, firstCharTransform: (Character) -> String) -> String {
    var result = ""
    var normalCharsCount: UInt = 0 // non-separator characters count
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
  
  private static func _toSnakeOrKebabImp(string: String, separator: Character) -> String {
    enum PreviousCharKind {
      case uppercase
      case lowercase
      case separator
    }
    
    var result = ""
    var normalCharsCount: UInt = 0 // non-separator characters count
    var previousKind: PreviousCharKind?
    for character in string {
      if character == "_" || character == "-" {
        result.append(separator)
        previousKind = .separator
      } else { // normal (non-separator) character:
        if character.isUppercase {
          if let previousKind, !(previousKind == .separator), !(previousKind == .uppercase) {
            // append separator only before first Capitalised char in each word execpt first word, only if previous char
            // was not a separator.
            result.append(separator)
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
}
