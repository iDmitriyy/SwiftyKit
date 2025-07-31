//
//  UpdatableCopy.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

// MARK: - Macro Types

public enum UpdatableCopyMacro_ {}

extension UpdatableCopyMacro_ {
  /// R is used as availability Type-token for remove operation.
  /// Remove operation is only possible for Optional values, so R == Void is used for Optionals.
  /// For non-Optional values Never is used, so removing is impossible and it is statically proven.
  public struct CopyingChoice<NewValue, R> {
    fileprivate let variant: _CopyingChoice<NewValue, R>
    
    private init(variant: _CopyingChoice<NewValue, R>) {
      self.variant = variant
    }
    
    public static var takeValueFromSource: Self { Self(variant: .copyFromSource) }
    public static func new(_ newValue: NewValue) -> Self { Self(variant: .new(newValue)) }
    public static func removeCurrent(_ removeAvailabilityToken: R) -> Self { Self(variant: .removeCurrent(removeAvailabilityToken)) }
  }

  fileprivate enum _CopyingChoice<NewValue, R> {
    case copyFromSource
    case new(NewValue)
    case removeCurrent(R)
  }
}

extension UpdatableCopyMacro_.CopyingChoice: ExpressibleByNilLiteral where R == Void {
  public init(nilLiteral: ()) {
    self = .removeCurrent(nilLiteral)
  }
}

extension UpdatableCopyMacro_.CopyingChoice where R == Void {
  @available(*, unavailable, message: "Use nil literal instead")
  public static var removeCurrent: Self { .removeCurrent(Void()) }
}

// MARK: Choice functions

public func updatedCopy_optionalValue<V>(for choice: UpdatableCopyMacro_.CopyingChoice<V, Void>, currentValue: V?) -> V? {
  switch choice.variant {
    case .copyFromSource: currentValue
    case .new(let newValue): newValue
    case .removeCurrent: nil
  }
}

public func updatedCopy_value<V>(for choice: UpdatableCopyMacro_.CopyingChoice<V, Never>, currentValue: V) -> V {
  switch choice.variant {
    case .copyFromSource: currentValue
    case .new(let newValue): newValue
  }
}

// MARK: - Example

/*
struct Product {
  let name: String
  let price: Double
  let oldPrice: Double?

  func copyUpdating(
    name nameChoice: UpdatableCopyMacro.CopyingChoice<String, Never> = .takeValueFromSource,
    price priceChoice: UpdatableCopyMacro.CopyingChoice<Double, Never> = .takeValueFromSource,
    oldPrice oldPriceChoice: UpdatableCopyMacro.CopyingChoice<Double, Void> = .takeValueFromSource
  ) -> Self {
    
    return Self(
      name: updatedCopy_value(for: nameChoice, currentValue: self.name),
      price: updatedCopy_value(for: priceChoice, currentValue: self.price),
      oldPrice: updatedCopy_optionalValue(for: oldPriceChoice, currentValue: self.oldPrice)
    )
  }
}

private func testCopy(product: Product) {
  product.copyUpdating(name: .new("RenamedProduct"))
//product.copyWith(oldPrice: .new(99.9))
  product.copyUpdating(oldPrice: .new(99.9))
  product.copyUpdating(oldPrice: nil)
//   product.copyUpdating(oldPrice: .removeCurrent) // impossible, Error: 'removeCurrent' is unavailable: Use nil literal instead
}
*/
