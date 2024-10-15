import SwiftUI

public struct BaseModifier: ViewModifier {
  
  @MainActor
  public static var shared: Self = .init(locale: nil)
  
  public let locale: Locale?
  
  public init(locale: Locale?) {
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

extension View {
  
  consuming func map<Content: View>(
    @ViewBuilder transform: (consuming Self) -> Content
  ) -> some View {
    transform(self)
  }
  
}
