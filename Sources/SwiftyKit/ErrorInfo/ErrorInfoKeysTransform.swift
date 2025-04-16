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
    var result = ""
    var shouldCapitalizeNext = false
    for (intIndex, character) in string.enumerated() {
      if character == "_" {
        shouldCapitalizeNext = true
      } else if character == "-" {
        shouldCapitalizeNext = true
      } else {
        // TODO: If no transform was made, then self can be returned without making a copy to result.
        // save a flag to remeber if any trnasforms were made, save only current index and make actual transform
        // and result allocation only when trasform really needed.
        if character.isUppercase {
          if intIndex == 0 {
            result.append(character.lowercased()) // lowercase first letter if kebbab
          } else {
            result.append(character) // all uppercased letters (except first letter in kebab style) copied as is
          }
        } else {
          if !shouldCapitalizeNext {
            result.append(character)
          } else {
            result.append(character.uppercased())
          }
        }
        shouldCapitalizeNext = false
      } // end if
    } // end for
    return result
  }
  
  internal static func snakeCased(string: String) -> String {
    fatalError()
  }
  
  internal static func pascalCased(string: String) -> String {
    fatalError()
  }
  
  internal static func kebabCased(string: String) -> String {
    fatalError()
  }
}
