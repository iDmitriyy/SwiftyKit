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
//    var result = ""
//    var hadNonSepratorBefore = false
//    var previousWasSeprator = false
//    for (intIndex, character) in string.enumerated() {
//      if character == "_" {
//        previousWasSeprator = true
//      } else if character == "-" {
//        previousWasSeprator = true
//      } else {
//        // TODO: If no transform was made, then self can be returned without making a copy to result.
//        // save a flag to remeber if any trnasforms were made, save only current index and make actual transform
//        // and result allocation only when trasform really needed.
//        if character.isUppercase {
//          if intIndex == 0 {
//            result.append(character.lowercased()) // lowercase first letter if kebbab
//          } else {
//            result.append(character) // all uppercased letters (except first letter in kebab style) copied as is
//          }
//        } else {
//          if previousWasSeprator, hadNonSepratorBefore {
//            result.append(character.uppercased())
//          } else {
//            result.append(character)
//          }
//        }
//        hadNonSepratorBefore = true
//        previousWasSeprator = false
//      } // end if
//    } // end for
//    return hadNonSepratorBefore ? result : string
    toPascalOrCamel(string: string, firstCharTransform: { "\($0)" })
  }
  
  internal static func fromAnyStyleToPascalCased(string: String) -> String {
    toPascalOrCamel(string: string, firstCharTransform: { $0.uppercased() })
  }
  
  private static func toPascalOrCamel(string: String, firstCharTransform: (Character) -> String) -> String {
    var result = ""
    var normalCharsCount: UInt = 0
    var hadNormalCharsBefore: Bool { normalCharsCount != 0}
    var previousWasSeprator = false
    for character in string {
      if character == "_" {
        previousWasSeprator = true
      } else if character == "-" {
        previousWasSeprator = true
      } else { // non-separator character
        // TODO: If no transform was made, then self can be returned without making a copy to result.
        // save a flag to remeber if any trnasforms were made, save only current index and make actual transform
        // and result allocation only when trasform really needed.
        // Если после сепаратора то uppercased
        if previousWasSeprator {
          if hadNormalCharsBefore {
            result.append(character.uppercased())
          } else {
            result.append(firstCharTransform(character))
          }
        } else { // -h
          if normalCharsCount > 0 {
            result.append(character)
          } else {
            result.append(firstCharTransform(character))
          }
        }
        
//        if character.isUppercase {
//          if nonSeparatorCount == 0 {
//            // lowercase first letter for camel
//            // uppercase first letter for kebbab
//            result.append(firstCharTransform(character))
//          } else {
//            result.append(character) // all uppercased letters (except first letter) copied as is
//          }
//        } else { // "-h"
//          if previousWasSeprator, hadNormalCharsBefore { // camel
//            result.append(character.uppercased())
//          } else {
//            result.append(character)
//          }
//          
//          if previousWasSeprator { // pascal
//            result.append(character.uppercased())
//          } else {
//            result.append(character)
//          }
//        }
        normalCharsCount += 1
        previousWasSeprator = false
      } // end if
    } // end for
    return hadNormalCharsBefore ? result : string
  }
  
  internal static func snakeCased(string: String) -> String {
    fatalError()
  }
  
  
  
  internal static func kebabCased(string: String) -> String {
    fatalError()
  }
}
