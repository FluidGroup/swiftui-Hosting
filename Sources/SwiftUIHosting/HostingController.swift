import SwiftUI

final class HostingController<Content: View>: UIHostingController<Content> {

  var onViewDidLayoutSubviews: (UIViewController) -> Void = { _ in }

  private let accessibilityIdentifier: String?

  init(
    accessibilityIdentifier: String? = nil,
    safeAreaRegions: SafeAreaRegions,
    rootView: Content
  ) {

    self.accessibilityIdentifier = accessibilityIdentifier

    super.init(rootView: rootView)
    self.safeAreaRegions = safeAreaRegions
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
