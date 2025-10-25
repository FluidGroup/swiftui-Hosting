import SwiftUI

open class SwiftUIHostingViewController<Content: View>: UIViewController {

  public let configuration: SwiftUIHostingConfiguration

  private let content: (UIViewController) -> Content

  private let name: String
  private let file: StaticString
  private let function: StaticString
  private let line: UInt

  public init(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    configuration: SwiftUIHostingConfiguration = .init(),
    @ViewBuilder content: @escaping @MainActor (UIViewController) -> Content
  ) {

    self.configuration = configuration
    self.content = content

    self.name = name
    self.file = file
    self.function = function
    self.line = line

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func viewDidLoad() {

    super.viewDidLoad()

    let _content = content(self).modifier(configuration.baseModifier)

    #if DEBUG

      let hostingController = HostingController(
        accessibilityIdentifier: _typeName(Content.self),
        disableSafeArea: configuration.disableSafeArea,
        ignoresKeyboard: configuration.ignoresKeyboard,
        rootView: _content
      )

    #else

      let hostingController = HostingController(
        disableSafeArea: configuration.disableSafeArea,
        ignoresKeyboard: configuration.ignoresKeyboard,
        rootView: _content
      )

    #endif

    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.didMove(toParent: self)

    hostingController.view.backgroundColor = .clear
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])

  }

}

open class AnySwiftUIHostingViewController: SwiftUIHostingViewController<AnyView> {

  public init<AnyViewContent: View>(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    configuration: SwiftUIHostingConfiguration = .init(),
    @ViewBuilder content: @escaping @MainActor (UIViewController) -> AnyViewContent
  ) {
    super.init(
      name,
      file,
      function,
      line,
      configuration: configuration,
      content: { AnyView(content($0)) }
    )
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
