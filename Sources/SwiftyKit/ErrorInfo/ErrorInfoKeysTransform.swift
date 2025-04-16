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
      } else { // non-separator character
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
  
  internal static func snakeCased(string: String) -> String {
    fatalError()
  }
  
  
  
  internal static func kebabCased(string: String) -> String {
    fatalError()
  }
}
