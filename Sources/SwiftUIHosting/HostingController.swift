import SwiftUI

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content> {

  var onViewDidLayoutSubviews: (UIViewController) -> Void = { _ in }

  private let accessibilityIdentifier: String?

  init(
    accessibilityIdentifier: String? = nil,
    disableSafeArea: Bool,
    ignoresKeyboard: Bool,
    rootView: Content
  ) {

    self.accessibilityIdentifier = accessibilityIdentifier

    super.init(rootView: rootView)
    
    // waiting for iOS 16.4 as minimum deployment target
    _disableSafeArea = disableSafeArea

    // https://steipete.com/posts/disabling-keyboard-avoidance-in-swiftui-uihostingcontroller/
    if ignoresKeyboard {
      guard let viewClass = object_getClass(view) else { return }
      
      let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoresKeyboard")
      if let viewSubclass = NSClassFromString(viewSubclassName) {
        object_setClass(view, viewSubclass)
      }
      else {
        guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
        guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
        
        if let method = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
          let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in
            if ignoresKeyboard {
              
            } else {
              
            }
          }
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

  override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = accessibilityIdentifier
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    onViewDidLayoutSubviews(self)
  }
}
