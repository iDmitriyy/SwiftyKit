//
//  Optional.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 13.04.2025.
//

extension Optional {
  /// Method make code shorter. Intended for use inside throwable methods.
  /// Useful for replacing 'guard let' or 'if let' constructions with more convenient piece of code. Example:
  ///
  /// ```
  /// // Standart approach:
  /// guard let value = maybeValue else {
  ///   throw APIError.emptyData
  /// }
  ///
  /// // This approach:
  /// let value = try maybeValue.unwrapOrThrow(APIError.emptyData)
  /// ```
  @inlinable
  public func unwrapOrThrow(_ errorExpression: @autoclosure () -> some Error) throws -> Wrapped {
    guard let value = self else { throw errorExpression() }
    return value
  }
  
  @inlinable
  public func unwrapOrThrow(_ errorExpression: () -> some Error) throws -> Wrapped {
    guard let value = self else { throw errorExpression() }
    return value
  }
  
  @inlinable
  public func asResult<E: Error>(replacingNilWith error: @autoclosure () -> E) -> Result<Wrapped, E> {
    switch self {
    case .some(let value): .success(value)
    case .none: .failure(error())
    }
  }
}

extension Optional {
  @inlinable
  public func flattened<T>() -> T? where Wrapped == T? {
    switch self {
    case .none: nil
    case .some(let optionalValue): optionalValue
    }
  }
  
  @inlinable
  public func flattened<T>() -> T? where Wrapped == T?? {
    switch self {
    case .none: nil
    case .some(let doubledOptionalValue): doubledOptionalValue.flattened()
    }
  }
}

//extension Optional {
//  public static func typeOfWrapped() -> Wrapped.Type { Wrapped.self }
//  
//  public func typeOfWrapped() -> Wrapped.Type { Wrapped.self }
//}
