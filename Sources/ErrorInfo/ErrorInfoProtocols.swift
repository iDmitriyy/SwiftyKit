//
//  ErrorInfoProtocols.swift
//  swifty-kit
//
//  Created by tmp on 28/07/2025.
//

// MARK: - Error Info

public protocol InformativeError: Error {
  associatedtype ErrorInfoType: ErrorInfoCollection
  
  var info: ErrorInfoType { get }
}

/// This approach addresses several important concerns:
/// - Thread Safety: The Sendable requirement is essential to prevent data races and ensure safe concurrent access.
/// - String Representation: Requiring CustomStringConvertible forces developers to provide meaningful string representations for stored values, which is invaluable for debugging and logging. It also prevents unexpected behavior when converting values to strings.
/// - Collision Resolution: The Equatable requirement allows to detect and potentially resolve collisions if different values are associated with the same key. This adds a layer of robustness.
public typealias ErrorInfoValueType = CustomStringConvertible & Equatable & Sendable

public protocol ErrorInfoCollection: Collection, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
  typealias ValueType = Sendable
//  associatedtype ValueType: Sendable = ErrorInfoValueType
//  func merging(with other: some ErrorInfoCollection) -> Self
  
  /// e.g. Later it can be decided to keep reference types as is, but interoplate value-types at the moment of passing them to ErrorInfo subscript.
//  @_disfavoredOverload subscript(_: String, _: UInt) -> (any ValueType)? { get set }
  
//  static func merged(_ infos: Self...) -> Self
//  func asLegacyDictionary() -> [String: Any]
}

/*
 Design principles:
 - Instances Error-info instances must be able to merge.
 - Merge operation must prevent data loss. Legacy [String: Any], as a dictionary type, have merge function, but it only
 allows to choose one value when resolving collisions, which mostly always cause data loss, except situations when values
 were equal. If they are refernce-types, they can be equal by ==, but be different instances comparing with ===. This knowledge
 can be important.
 Error-info types must provide merging strategies. Lets see to some of them (when keys collision happens):
   - put all values to array or some other container. While it is possble, there is a lack of information from each context
     which value was.
   - modify one of two equal keys to resolve collisions. Some variants:
     - add a random suffix / prefix to one of two keys
     - add `file_line` to each key, so it is at least clear where Error info instance was created. As Error infos are created
       a lot in codebase, this can be bad for binary size.
       ? Inspect if binary size increases when #fileID is used many time in the same file. Does compiler create many StaticString
       or it is smart enough to create one string for each file and share it.
     - add some short version of #fileID (3 chars). This need a macro or some other kind of compile-time evalution,
       and some sharing of this short string to share to prevent making lots of equal values.
     When error infos are merged in context of errors or error chains, error domain and code can be used for resolving collision.
 - All Error-info Types, that will be made in future, should able to be compatible with each other for merging.
 */

public protocol ErrorInfoType: ErrorInfoCollection {
  
}

func test(errorInfo: ErrorInfoCollection) {
  [3].isEmpty
  
  errorInfo.isEmpty
}

// extension ErrorInfoProtocol {
//  public init(dictionaryLiteral elements: (String, (any ValueType)?)..., line: UInt = #line) {
//    elements.forEach { key, value in
//      self[key, line] = value
//    }
//  }
// }

internal protocol ErrorInfoInternal {
  associatedtype Storage
  
  var storage: Storage { get }
}

extension ErrorInfo: ErrorInfoInternal {}
