//
//  ContentView.swift
//  Development
//
//  Created by Muukii on 2023/03/09.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationView {
      List {        
        NavigationLink("Content") {
          BookFoo()
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

struct BookFoo: View, PreviewProvider {
  var body: some View {
    Content()
  }

  static var previews: some View {
    Self()
  }

  private struct Content: View {

    var body: some View {
      Text("Book")
    }
  }
}
