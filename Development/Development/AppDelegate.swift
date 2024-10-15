import UIKit
import SwiftUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let newWindow = UIWindow()
    newWindow.rootViewController = UIHostingController.init(rootView: ContentView())
    newWindow.makeKeyAndVisible()
    self.window = newWindow
    return true
  }

}
