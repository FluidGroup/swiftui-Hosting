import SwiftUI

public struct BaseModifier: ViewModifier {
  
  public nonisolated static var shared: Self {
    get { _shared.value }
    set { _shared.value = newValue }
  }
  
  private nonisolated static let _shared: Atomic<Self> = .init(.init(locale: nil))
  
  public let locale: Locale?
    
  public nonisolated init(locale: Locale?) {
    self.locale = locale
  }
  
  public func body(content: Content) -> some View {
    content
      .map {
        if let locale {
          $0.environment(\.locale, locale)
        } else {
          $0
        }
      }
  }
  
}

private final class Atomic<Value>: @unchecked Sendable {
  
  var value: Value {
    get {
      lock.lock()
      defer { lock.unlock() }
      return _value
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _value = newValue
    }
  }
  
  private var _value: Value
  private let lock = NSLock()
  
  init(_ value: consuming Value) {
    self._value = value
  }
  
}

extension View {
  
  consuming func map<Content: View>(
    @ViewBuilder transform: (consuming Self) -> Content
  ) -> some View {
    transform(self)
  }
  
}
