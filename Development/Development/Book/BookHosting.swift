import SwiftUI
import SwiftUIHosting

@available(iOS 14.0, *)
struct BookHosting: View, PreviewProvider {
  var body: some View {
    ContentView()
  }

  static var previews: some View {
    Self()
  }

  private struct ContentView: View {

    @State var text: String = ""

    var body: some View {
      HostingViewHost {
        VStack {
          Color.purple.frame(width: 100, height: 100)
          TextField("Text", text: $text)
          Color.purple.frame(width: 100, height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .background(Color(white: 0.1))
      }
//      .ignoresSafeArea()
//      .background(Color(white: 0.1))
    }
  }
}

private struct HostingViewHost<Content: View>: UIViewRepresentable {

  let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  func makeUIView(context: Context) -> UIView {
//    _UIHostingView(rootView: AnyView(content()))
    SwiftUIHostingView {
      content()
    }
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    // Nothing
  }
}
