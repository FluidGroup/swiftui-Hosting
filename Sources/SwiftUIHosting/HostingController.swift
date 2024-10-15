import SwiftUI

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content> {

  var onViewDidLayoutSubviews: (UIViewController) -> Void = { _ in }

  private let accessibilityIdentifier: String?

  init(
    accessibilityIdentifier: String? = nil,
    disableSafeArea: Bool,
    rootView: Content
  ) {

    self.accessibilityIdentifier = accessibilityIdentifier

    super.init(rootView: rootView)
    
    // waiting for iOS 16.4 as minimum deployment target
    _disableSafeArea = disableSafeArea

  }

  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = accessibilityIdentifier
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    onViewDidLayoutSubviews(self)
  }
}
