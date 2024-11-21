//
//  ContentView.swift
//  Development
//
//  Created by Muukii on 2023/03/09.
//

import SwiftUI
import SwiftUIHosting

struct ContentView: View {
  var body: some View {
    NavigationView {
      List {        
        NavigationLink("Content") {
          BookSizing()          
        }
        NavigationLink("Keyboard Avoidance") {
          KeyboardAvoidanceViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct KeyboardAvoidanceViewControllerRepresentable: UIViewControllerRepresentable {
  
  func makeUIViewController(context: Context) -> some UIViewController {
    KeyboardAvoidanceViewController()
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
  }
  
}

final class KeyboardAvoidanceViewController: UIViewController, UITextFieldDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let hostingView = SwiftUIHostingView(configuration: .init(ignoresKeyboard: false)) { 
      Text("Hello")
    }
    
    view.addSubview(hostingView)
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      hostingView.rightAnchor.constraint(equalTo: view.rightAnchor),
      hostingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      hostingView.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])
    
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.delegate = self
    
    textField.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(textField)
    
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
      textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
