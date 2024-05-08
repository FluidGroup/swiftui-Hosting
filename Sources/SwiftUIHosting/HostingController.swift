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

    if true {
      guard let viewClass = object_getClass(view) else { return }

      let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoresKeyboard")
      if let viewSubclass = NSClassFromString(viewSubclassName) {
        object_setClass(view, viewSubclass)
      }
      else {
        guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
        guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }

        if let method = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
          let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
          class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"),
                          imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method))
        }
        objc_registerClassPair(viewSubclass)
        object_setClass(view, viewSubclass)
      }
    }

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
