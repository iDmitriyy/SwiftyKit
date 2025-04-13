//
//  String.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.04.2025.
//

extension StringProtocol {
  // MARK: Trimming
  
  @inlinable
  public func trimmingCharacters(except characterSet: CharacterSet) -> String {
    trimmingCharacters(in: characterSet.inverted)
  }
  
  @inlinable
  public func trimmingWhitespacesAndNewlines() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }

  // MARK: Contains
    
  @inlinable
  public func containsCharacters(in characterSet: CharacterSet) -> Bool {
    unicodeScalars.contains(where: characterSet.contains(_:))
  }

  @inlinable
  public func containsCharacters(except characterSet: CharacterSet) -> Bool {
    containsCharacters(in: characterSet.inverted)
  }
  
  // MARK: Count
  
  @inlinable
  public func countCharacters(in characterSet: CharacterSet) -> Int {
    unicodeScalars.count(where: characterSet.contains(_:))
  }
  
  @inlinable
  public func countCharacters(except characterSet: CharacterSet) -> Int {
    countCharacters(in: characterSet.inverted)
  }
}

// MARK: - Removing

extension String {
  public func removingCharacters(except characterSet: CharacterSet) -> Self {
    String(Substring(self).removingCharacters(except: characterSet))
  }
  
  public func removingCharacters(in characterSet: CharacterSet) -> Self {
    String(Substring(self).removingCharacters(in: characterSet))
  }
}

extension Substring {
  public func removingCharacters(except characterSet: CharacterSet) -> Self {
    let scalars = unicodeScalars.filter(characterSet.contains(_:))
    return Self(scalars)
  }
  
  public func removingCharacters(in characterSet: CharacterSet) -> Self {
    removingCharacters(except: characterSet.inverted)
  }
}
