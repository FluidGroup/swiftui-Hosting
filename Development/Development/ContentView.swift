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
          BookSizing()
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

