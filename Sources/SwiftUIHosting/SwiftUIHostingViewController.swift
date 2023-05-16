import SwiftUI

open class SwiftUIHostingViewController: UIViewController {

  public let configuration: SwiftUIHostingView.Configuration
  private let content: (UIViewController) -> AnyView

  public init<Content: View>(
    configuration: SwiftUIHostingView.Configuration = .init(),
    content: @escaping (Self) -> Content
  ) {
    self.configuration = configuration
    self.content = { AnyView(content(unsafeDowncast($0, to: Self.self))) }
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func viewDidLoad() {

    let _content = content(self)

    let contentView = SwiftUIHostingView(configuration: configuration) { _content }

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
