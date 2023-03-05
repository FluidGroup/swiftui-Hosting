import SwiftUI

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content> {

  var onViewDidLayoutSubviews: (UIViewController) -> Void = { _ in }

  init(disableSafeArea: Bool, rootView: Content) {
    super.init(rootView: rootView)

    // https://www.notion.so/muukii/UIHostingController-safeArea-issue-ec66a560970c4a1cb44f21cc448bc513?pvs=4
#if USE_SWIZZLING
    _ = _once_
    _fixing_safeArea = disableSafeArea
#else
    _disableSafeArea = disableSafeArea
#endif
  }
  
  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    onViewDidLayoutSubviews(self)
  }
}

#if USE_SWIZZLING

private let _once_: Void = {
  UIView.replace()
}()

private var _key: Void?

extension UIView {

  fileprivate static func replace() {

    method_exchangeImplementations(
      class_getInstanceMethod(self, #selector(getter:UIView.safeAreaInsets))!,
      class_getInstanceMethod(self, #selector(getter:UIView._hosting_safeAreaInsets))!
    )

    method_exchangeImplementations(
      class_getInstanceMethod(self, #selector(getter:UIView.safeAreaLayoutGuide))!,
      class_getInstanceMethod(self, #selector(getter:UIView._hosting_safeAreaLayoutGuide))!
    )

  }

  fileprivate var _fixing_safeArea: Bool {
    get {
      (objc_getAssociatedObject(self, &_key) as? Bool) ?? false
    }
    set {
      objc_setAssociatedObject(self, &_key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }

  @objc dynamic var _hosting_safeAreaInsets: UIEdgeInsets {
    if _fixing_safeArea {
      return .zero
    } else {
      return self._hosting_safeAreaInsets
    }
  }

  @objc dynamic var _hosting_safeAreaLayoutGuide: UILayoutGuide? {
    if _fixing_safeArea {
      return nil
    } else {
     return self._hosting_safeAreaLayoutGuide
    }
  }

}

#endif
