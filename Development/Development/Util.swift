import SwiftUI
import UIKit
import SwiftUIHosting

@MainActor
func measureSize(content: some View, targetSize: CGSize) {

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
