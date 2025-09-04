//
//  Either.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

/// Either represents duality, a value that can either be of a type or another.
public enum Either<L: ~Copyable, R: ~Copyable>: ~Copyable {
  case left(L)
  case right(R)
}

extension Either: Copyable where L: Copyable, R: Copyable {}

extension Either: BitwiseCopyable where L: BitwiseCopyable, R: BitwiseCopyable {}

extension Either: Equatable where L: Equatable, R: Equatable {}

extension Either: Hashable where L: Hashable, R: Hashable {}

extension Either: Sendable where L: Sendable, R: Sendable {}

extension Either {
  public var leftValue: L? {
    switch self {
    case .left(let leftValue): leftValue
    case .right: nil
    }
  }

  public var rightValue: R? {
    switch self {
    case .right(let rightValue): rightValue
    case .left: nil
    }
  }
}

extension Either where L == R {
  /// Когда L == R, можно получить неопциональный underlying value
  public var wrappedValue: L {
    switch self {
    case .left(let value): value
    case .right(let value): value
    }
  }
  
  subscript<P>(dynamicMember keyPath: KeyPath<L, P>) -> P {
    wrappedValue[keyPath: keyPath]
  }
  
//  subscript<P>(dynamicMember keyPath: WritableKeyPath<L, P>) -> P { // TODO: imp
//    get { wrappedValue[keyPath: keyPath] }
//    set { wrappedValue[keyPath: keyPath] = newValue }
//  }
  
  subscript<P>(dynamicMember keyPath: ReferenceWritableKeyPath<L, P>) -> P {
    get { wrappedValue[keyPath: keyPath] }
    set { wrappedValue[keyPath: keyPath] = newValue }
  }
}

extension Either where L: ~Copyable, R: ~Copyable {
  public consuming func mapLeft<NewLeft>(_ transform: (consuming L) -> NewLeft) -> Either<NewLeft, R> {
    switch consume self {
    case .left(let value): .left(transform(value))
    case .right(let value): .right(value)
    }
  }
  
  public consuming func mapRight<NewRight>(_ transform: (consuming R) -> NewRight) -> Either<L, NewRight> {
    switch consume self {
    case .left(let value): .left(value)
    case .right(let value): .right(transform(value))
    }
  }
  
  public consuming func swapped() -> Either<R, L> {
    switch consume self {
    case .left(let value): .right(value)
    case .right(let value): .left(value)
    }
  }
}

extension Either where L: ~Copyable, R: ~Copyable {
  public var isLeft: Bool {
    switch self {
    case .left: true
    case .right: false
    }
  }
  
  public var isRight: Bool { !isLeft }
}

extension Either where R: Error, L: ~Copyable {
  public consuming func asResult() -> Result<L, R> {
    switch consume self {
    case .left(let leftValue): .success(leftValue)
    case .right(let rightValue): .failure(rightValue)
    }
  }
}

extension Either where L: Error, R: ~Copyable {
  public consuming func asResult() -> Result<R, L> {
    switch consume self {
    case .left(let leftValue): .failure(leftValue)
    case .right(let rightValue): .success(rightValue)
    }
  }
}

extension Either where L: Error, R: Error  {
  // FIXME: - when both L & R of type Error ? deprecated | *unavailable
  public func asResult() -> Result<R, L> {
    switch self {
    case .left(let leftValue): .failure(leftValue)
    case .right(let rightValue): .success(rightValue)
    }
  }
}

/*
 extension Either: Error where L: Error, R: Error {}

 extension Either: LocalizedError where L: LocalizedError, R: LocalizedError {
   public var errorDescription: String? {
     switch self {
     case .left(let l): return l.errorDescription
     case .right(let r): return r.errorDescription
     }
   }
 }

 extension Either: CustomDebugStringConvertible where L: CustomDebugStringConvertible, R: CustomDebugStringConvertible {
   public var debugDescription: String {
     switch self {
     case .left(let l): return l.debugDescription
     case .right(let r): return r.debugDescription
     }
   }
 }

 extension Either: CustomStringConvertible where L: CustomStringConvertible, R: CustomStringConvertible {
   public var description: String {
     switch self {
     case .left(let l): return l.description
     case .right(let r): return r.description
     }
   }
 }

 extension Either: CustomNSError where L: CustomNSError, R: CustomNSError {
   public static var errorDomain: String { "Either error" }

   /// The error code within the given domain.
   public var errorCode: Int {
     switch self {
     case .left(let l): return l.errorCode
     case .right(let r): return r.errorCode
     }
   }

   /// The user-info dictionary.
   public var errorUserInfo: [String: Any] {
     switch self {
     case .left(let l): return l.errorUserInfo
     case .right(let r): return r.errorUserInfo
     }
   }
 }

 extension Either: BaseError where L: BaseError, R: BaseError {
   public var domainShortCode: String {
     switch self {
     case .left(let l): return l.domainShortCode
     case .right(let r): return r.domainShortCode
     }
   }
  
   public var underlying: (any BaseError)? {
     switch self {
     case .left(let l): return l.underlying
     case .right(let r): return r.underlying
     }
   }
  
   public var primaryUserInfo: ErrorOrderedInfo {
     switch self {
     case .left(let l): return l.primaryUserInfo
     case .right(let r): return r.primaryUserInfo
     }
   }
  
   public var userInfo: ErrorInfo {
     switch self {
     case .left(let l): return l.userInfo
     case .right(let r): return r.userInfo
     }
   }
  
   public var localizedMessage: String {
     switch self {
     case .left(let l): return l.localizedMessage
     case .right(let r): return r.localizedMessage
     }
   }
  
   public var providesCodeChain: Bool {
     switch self {
     case .left(let l): return l.providesCodeChain
     case .right(let r): return r.providesCodeChain
     }
   }
  
   public var code: Int {
     switch self {
     case .left(let l): return l.code
     case .right(let r): return r.code
     }
   }
 }

 */

extension Result {
  public func asEither() -> Either<Success, Failure> {
    switch self {
    case .success(let value): .left(value)
    case .failure(let error): .right(error)
    }
  }
}

//extension Either: Decodable where L: Decodable, R: Decodable {
//  public init(from decoder: any Decoder) throws {
//    do {
//      let decodedInstance = try L(from: decoder)
//      self = .left(decodedInstance)
//    } catch let leftError {
//      do {
//        let decodedInstance = try R(from: decoder)
//        self = .right(decodedInstance)
//      } catch let rightError {
//        let debugMessage = "EitherMappingFailed, " +
//          "Type: \(Self.self), \n left: \(String(reflecting: leftError))\nright: \(String(reflecting: rightError))"
//        throw JsonMappingError(code: .typeCastFailed,
//                               typeOfValue: Self.self,
//                               debugMessage: debugMessage)
//      }
//    }
//  }
//}
