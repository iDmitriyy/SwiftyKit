//
//  CharacterSet.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

extension CharacterSet {
  /// "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  public static let englishAlphabetUppercased = CharacterSet(charactersIn: String.englishAlphabetUppercasedString)

  /// "abcdefghijklmnopqrstuvwxyz"
  public static let englishAlphabetLowercased = CharacterSet(charactersIn: String.englishAlphabetLowercasedString)

  /// "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  public static let englishAlphabet = englishAlphabetUppercased.union(englishAlphabetLowercased)
}

extension CharacterSet {
  /// "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
  public static let russianAlphabetUppercased = CharacterSet(charactersIn: String.russianAlphabetUppercasedString)

  /// "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
  public static let russianAlphabetLowercased = CharacterSet(charactersIn: String.russianAlphabetLowercasedString)

  /// "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
  public static let russianAlphabet = russianAlphabetUppercased.union(russianAlphabetLowercased)
}

extension CharacterSet {
  /// "0123456789"
  public static let arabicNumerals = CharacterSet(charactersIn: String.arabicNumeralsString)
  
  /// "0123456789ABCDEFabcdef"
  public static let hex = CharacterSet.arabicNumerals.union(CharacterSet(charactersIn: "ABCDEFabcdef"))
}

extension String {
  /// "0123456789"
  fileprivate static let arabicNumeralsString = "0123456789"
  
  /// "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  fileprivate static let englishAlphabetUppercasedString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  
  /// "abcdefghijklmnopqrstuvwxyz"
  fileprivate static let englishAlphabetLowercasedString = "abcdefghijklmnopqrstuvwxyz"
  
  /// "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
  fileprivate static let russianAlphabetUppercasedString = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
  
  /// "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
  fileprivate static let russianAlphabetLowercasedString = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
}

extension CharacterSet {
  /// Phone number symbols: "0123456789+-()*#"
  public static let phoneNumberSymbols = arabicNumerals.union(CharacterSet(charactersIn: "+-()*#"))
  
  /// phoneNumberSymbols + space
  public static let phoneNumberInputSymbols = phoneNumberSymbols.union(CharacterSet(charactersIn: " "))
}

// This might be not needed when `GraphemeClusterSet` will be done. Such a type will alllow to have:
// - Non-empty variants for random element without optional unwrapping
// - It will be a right namespace as currently CharacterSet is.

// `GraphemeClusterSet` under the hood will contain 2 separate storages for single unicode scalars and grapheme clusters
// that contain several scalars.
