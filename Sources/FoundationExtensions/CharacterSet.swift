//
//  CharacterSet.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public import struct NonEmpty.NonEmptyString

extension CharacterSet {
  /// "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  public static let englishAlphabetUppercased = CharacterSet(charactersIn: String.englishAlphabetUppercasedString.rawValue)

  /// "abcdefghijklmnopqrstuvwxyz"
  public static let englishAlphabetLowercased = CharacterSet(charactersIn: String.englishAlphabetLowercasedString.rawValue)

  /// "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  public static let englishAlphabet = englishAlphabetUppercased.union(englishAlphabetLowercased)
}

extension CharacterSet {
  /// "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
  public static let russianAlphabetUppercased = CharacterSet(charactersIn: String.russianAlphabetUppercasedString.rawValue)

  /// "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
  public static let russianAlphabetLowercased = CharacterSet(charactersIn: String.russianAlphabetLowercasedString.rawValue)

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
  public static let arabicNumeralsString = "0123456789"
  
  /// "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  public static let englishAlphabetUppercasedString: NonEmptyString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  
  /// "abcdefghijklmnopqrstuvwxyz"
  public static let englishAlphabetLowercasedString: NonEmptyString = "abcdefghijklmnopqrstuvwxyz"
  
  /// "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
  public static let russianAlphabetUppercasedString: NonEmptyString = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
  
  /// "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
  public static let russianAlphabetLowercasedString: NonEmptyString = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
}

extension CharacterSet {
  /// Phone number symbols: "0123456789+-()*#"
  public static let phoneNumberSymbols = arabicNumerals.union(CharacterSet(charactersIn: "+-()*#"))
  
  /// phoneNumberSymbols + space
  public static let phoneNumberInputSymbols = phoneNumberSymbols.union(CharacterSet(charactersIn: " "))
}
