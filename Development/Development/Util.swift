import SwiftUI
import UIKit
import SwiftUIHosting

func measureSize(content: some View, targetSize: CGSize) {

  do {
    if #available(iOS 15.0, *) {
      let a = _makeUIHostingController(AnyView(content), tracksContentSize: true, secure: false)
      print(a)
    } else {
      // Fallback on earlier versions
    }

  }

  do {
    let size = UIHostingController(rootView: content).sizeThatFits(in: targetSize)
    print("System SizeThatFits:", size)
  }

  do {
    let size = SwiftUIHostingView(content: { content }).sizeThatFits(targetSize)
    print("Custom SizeThatFits:", size)
  }

  do {
    let size = UIHostingController(rootView: content).view.systemLayoutSizeFitting(targetSize)
    print("AutoLayout:", size)
  }
}
