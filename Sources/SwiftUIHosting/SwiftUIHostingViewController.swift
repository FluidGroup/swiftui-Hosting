import SwiftUI

open class SwiftUIHostingViewController: UIViewController {

  public let configuration: SwiftUIHostingView.Configuration
  private let content: (UIViewController) -> AnyView

  private let name: String
  private let file: StaticString
  private let function: StaticString
  private let line: UInt

  public init<Content: View>(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    configuration: SwiftUIHostingView.Configuration = .init(),
    content: @escaping (Self) -> Content
  ) {

    self.configuration = configuration
    self.content = { AnyView(content(unsafeDowncast($0, to: Self.self))) }

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

    let _content = content(self)

    let contentView = SwiftUIHostingView(
      name,
      file,
      function,
      line,
      configuration: configuration
    ) { _content }

    view.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])

  }

}
