//
//  FileLine.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public struct StaticFileLine: Sendable, BitwiseCopyable {
  public let fileID: StaticString // StaticString is BitwiseCopyable
  public let line: UInt
  
  public init(fileID: StaticString = #fileID, line: UInt = #line) {
    (self.fileID, self.line) = (fileID, line)
  }
  
  public static func this(fileID: StaticString = #fileID, line: UInt = #line) -> Self {
    Self(fileID: fileID, line: line)
  }
  
  /// The name of the source file.
  ///
  /// The name of the source file is derived from this instance's ``fileID`` property. It consists of the substring of the file ID after the last
  /// forward-slash character (`"/"`.) For example, if the value of this
  /// instance's ``fileID`` property is `"FoodTruck/WheelTests.swift"`, the
  /// file name is `"WheelTests.swift"`.
  ///
  /// The structure of file IDs is described in the documentation for
  /// [`#fileID`](https://developer.apple.com/documentation/swift/fileid())
  /// in the Swift standard library.
  ///
  /// ## See Also
  /// - ``moduleName``
  public var fileName: String {
    extractFileName(fromFileID: fileID)
  }

  /// The name of the module containing the source file.
  ///
  /// The name of the module is derived from this instance's ``fileID``
  /// property. It consists of the substring of the file ID up to the first
  /// forward-slash character (`"/"`.) For example, if the value of this
  /// instance's ``fileID`` property is `"FoodTruck/WheelTests.swift"`, the
  /// module name is `"FoodTruck"`.
  ///
  /// The structure of file IDs is described in the documentation for the
  /// [`#fileID`](https://developer.apple.com/documentation/swift/fileid())
  /// macro in the Swift standard library.
  ///
  /// ## See Also
  ///
  /// - ``fileID``
  /// - ``fileName``
  /// - [`#fileID`](https://developer.apple.com/documentation/swift/fileid())
  public var moduleName: String {
    extractModuleName(fromFileID: fileID)
  }
}

internal struct StaticFileLineFunc: Sendable, BitwiseCopyable {
  internal let fileID: StaticString
  internal let line: UInt
  internal let function: StaticString
  
  internal init(file: StaticString = #fileID, line: UInt = #line, function: StaticString = #function) {
    (fileID, self.line, self.function) = (file, line, function)
  }
  
  internal static func this(file: StaticString = #fileID, line: UInt = #line, function: StaticString = #function) -> Self {
    Self(file: file, line: line, function: function)
  }
}
