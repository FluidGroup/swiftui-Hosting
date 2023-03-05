import SwiftUI

/// A view that hosts SwiftUI for UIKit environment.
open class SwiftUIHostingView: UIView {

  public struct Configuration {

    /**
     Registers internal hosting controller into the nearest view controller's children.

     Apple developer explains why we need to UIHostinController should be a child of the view controller.
     ```
     When using UIHostingController, make sure to always add the view controller together with the view to your app.

     Many SwiftUI features, such as toolbars, keyboard shortcuts, and views that use UIViewControllerRepresentable, require a connection to the view controller hierarchy in UIKit to integrate properly, so never separate a hosting controller's view from the hosting controller itself.
     ```
     */
    public var registersAsChildViewController: Bool

    /**
     Fixes handling safe area issue
     https://www.notion.so/muukii/UIHostingController-safeArea-issue-ec66a560970c4a1cb44f21cc448bc513?pvs=4
     */
    public var disableSafeArea: Bool

    public init(
      registersAsChildViewController: Bool = true,
      disableSafeArea: Bool = true
    ) {
      self.registersAsChildViewController = registersAsChildViewController
      self.disableSafeArea = disableSafeArea
    }
  }

  private var hostingController: HostingController<RootView>

  private let proxy: Proxy = .init()

  public let configuration: Configuration

  public convenience init<Content: View>(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    configuration: Configuration = .init(),
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.init(
      name,
      file,
      function,
      line,
      configuration: configuration
    )
    setContent(content: content)
  }

  // MARK: - Initializers

  public init(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    configuration: Configuration = .init()
  ) {
    self.configuration = configuration

    self.hostingController = HostingController(
      disableSafeArea: configuration.disableSafeArea,
      rootView: RootView(proxy: proxy)
    )

    super.init(frame: .null)

    #if DEBUG
    let file = URL(string: file.description)?.deletingPathExtension().lastPathComponent ?? "unknown"
    self.accessibilityIdentifier = [
      name,
      file,
      function.description,
      line.description,
    ]
    .joined(separator: ".")
    #endif

    hostingController.view.backgroundColor = .clear

    addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingController.view.leftAnchor.constraint(equalTo: leftAnchor),
    ])

    hostingController.onViewDidLayoutSubviews = { controller in
      // TODO: Reduces number of calling invalidation, it's going to be happen even it's same value.
      controller.view.invalidateIntrinsicContentSize()
    }

  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  /// Returns calculated size using internal hosting controller
  open override func sizeThatFits(_ size: CGSize) -> CGSize {
    hostingController.sizeThatFits(in: size)
  }

  open override func didMoveToWindow() {

    super.didMoveToWindow()

    if configuration.registersAsChildViewController {
      // https://muukii.notion.site/Why-we-need-to-add-UIHostingController-to-view-controller-chain-14de20041c99499d803f5a877c9a1dd1

      if let _ = window {
        if let parentViewController = self.findNearestViewController() {
          parentViewController.addChild(hostingController)
          hostingController.didMove(toParent: parentViewController)
        } else {
          assertionFailure()
        }
      } else {
        hostingController.willMove(toParent: nil)
        hostingController.removeFromParent()
      }
    }
  }

  // MARK: -

  public final func setContent<Content: SwiftUI.View>(
    @ViewBuilder content: @escaping () -> Content
  ) {
    proxy.content = {
      return SwiftUI.AnyView(
        content()
      )
    }
  }

}

final class Proxy: ObservableObject {
  @Published var content: () -> SwiftUI.AnyView? = { nil }

  init() {
  }
}

struct RootView: SwiftUI.View {
  @ObservedObject var proxy: Proxy

  var body: some View {
    proxy.content()
  }
}
