//
//  RefBox.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

public struct UnownedRef<E> {
  private unowned let _instance: AnyObject
  
  public var wrappedValue: E { _instance as! E }
  
  public var instance: E { wrappedValue }
  
  public init(_ instance: E, prove typeCastToAnyObject: (E) -> any AnyObject = { $0 }) {
    let typeCasted = typeCastToAnyObject(instance)
    // TODO: - ? builtin assert can be used
    // is it even needed?  'No exact matches in call to initializer ' so it won't compile
//    assertError((instance as AnyObject) === typeCasted,
//                ConditionalError(code: .notEqualObjects, info: ["T": "\(E.self)", "typeCasted": "\(typeCasted)"]))
    
    self._instance = typeCasted
  }
  // TODO: - seems that compiler can now open existential, so init above not nedded anymore
  public init(_ instance: E) where E: AnyObject {
    self._instance = instance
  }
}

public struct WeakExRef<T> {
  private weak var instance: AnyObject?
  
  public var wrappedValue: T? {
    if let instance {
      let typeCasted: T = instance as! T
      return typeCasted
    } else {
      return nil
    }
  }
  
  public init<U>(_ instance: U, _ proveSubtyping: (U) -> T) where U: AnyObject {
    self.instance = instance
  }
  
  public init(_ instance: T) where T: AnyObject {
    self.instance = instance
  }
}
