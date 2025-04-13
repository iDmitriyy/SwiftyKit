//
//  Namespace.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

/// Marker protocol for using and marking uninhabitat types as Namespace.
/// `Namespacing` term is selected to avoid naming collision with SwiftUI.Namespace
@_marker public protocol Namespacing: Sendable, ~Copyable, ~Escapable {
  //
}
