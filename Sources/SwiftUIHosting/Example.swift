#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
@Observable
private final class Model {
  var count: Int = 0
}

@available(iOS 17.0, *)
#Preview {
  let model = Model()
  return SwiftUIHostingView { 
    Button("Count: \(model.count)") {
      model.count += 1
    }
  }
}

#endif
