import SwiftUI

/// A view that hosts SwiftUI for UIKit environment.
open class SwiftUIHostingView: UIView {

  public enum SizeMeasureMode {

    /// Use systemLayoutSizeFitting
    case autoLayout

    /// Use sizeThatFits
    case systemSizeThatFits

    /// Use sizeThatFits with UIView.layoutFittingCompressedSize if the value is infinite
    case compressedSizeThatFits
  }

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

    public var sizeMeasureMode: SizeMeasureMode
    
    public var baseModifier: BaseModifier

    public init(
      registersAsChildViewController: Bool = true,
      disableSafeArea: Bool = true,
      sizeMeasureMode: SizeMeasureMode = .systemSizeThatFits,
      baseModifier: BaseModifier = .shared
    ) {
      self.registersAsChildViewController = registersAsChildViewController
      self.disableSafeArea = disableSafeArea
      self.sizeMeasureMode = sizeMeasureMode
      self.baseModifier = baseModifier
    }
  }

  private let hostingController: HostingController<AnyView>

  public let configuration: Configuration

  public init<Content: View>(
    _ name: String = "",
    _ file: StaticString = #file,
    _ function: StaticString = #function,
    _ line: UInt = #line,
    configuration: Configuration = .init(),
    @ViewBuilder content: () -> Content
  ) {

    self.configuration = configuration
    
    let usingContent = content().modifier(configuration.baseModifier)

    #if DEBUG

    self.hostingController = HostingController(
      accessibilityIdentifier: _typeName(Content.self),
      disableSafeArea: configuration.disableSafeArea,
      rootView: AnyView(usingContent)
    )

    #else

    self.hostingController = HostingController(
      disableSafeArea: configuration.disableSafeArea,
      rootView: AnyView(usingContent)
    )

    #endif

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

    switch configuration.sizeMeasureMode {
    case .systemSizeThatFits:

      let fittingSize = hostingController.sizeThatFits(in: size)

      return fittingSize

    case .autoLayout:

      let fittingSize = hostingController.view.systemLayoutSizeFitting(size)

      return fittingSize

    case .compressedSizeThatFits:

      var fixedSize = size

      if fixedSize.width == .infinity {
        fixedSize.width = UIView.layoutFittingCompressedSize.width
      }

      if fixedSize.height == .infinity {
        fixedSize.height = UIView.layoutFittingCompressedSize.height
      }

      let fittingSize = hostingController.sizeThatFits(in: fixedSize)

      return fittingSize

    }

  }

  open override func didMoveToWindow() {

    super.didMoveToWindow()

    registerParent()

  }

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()

    registerParent()
  }

  private func registerParent() {
    // https://muukii.notion.site/Why-we-need-to-add-UIHostingController-to-view-controller-chain-14de20041c99499d803f5a877c9a1dd1

    guard configuration.registersAsChildViewController else {
      return
    }

    guard let _ = window else {
      return
    }

    // find a view controller nearest using responder chain.
    if let parentViewController = self.findNearestViewController() {

      if parentViewController == hostingController.parent {
        // it's already associated with proposed view controller as parent.
      } else {

        if let _ = hostingController.parent {
          // if associated with different parent view controller, unregister first.
          hostingController.willMove(toParent: nil)
          hostingController.removeFromParent()
        }

        // register parent view controller
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
      }

    } else {
      assertionFailure()
    }
  }

  /**
   Remove underlying hosting view controller from the parent view controller.
   You may remove parent view controller manually.
   However, it will have a new parent view controller when this view got new window or new view.
   */
  public func unregisterParent() {
    hostingController.willMove(toParent: nil)
    hostingController.removeFromParent()
  }

}
