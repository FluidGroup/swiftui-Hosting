import SwiftUI

struct BookSizing: View, PreviewProvider {
  var body: some View {
    Content()
  }

  static var previews: some View {
    Self()
  }

  private struct Content: View {

    var body: some View {
      Button("Measure") {

        measureSize(content: TargetContent(), targetSize: .init(width: 70, height: CGFloat.infinity))

      }
    }
  }

  struct TargetContent: View {

    var body: some View {
      Text("Hello")
    }
  }
}

