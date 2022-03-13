//
//  MainView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 12.03.22.
//

import SwiftUI

struct RedView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
                .padding()
            }
            List {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Content")/*@END_MENU_TOKEN@*/
            } .listStyle(.inset)
        }
    }
}
struct BlueView: View {
    var body: some View {
        Color.blue
    }
}

struct MainView: View {
    var body: some View {
        TabView {
           RedView()
             .tabItem {
                Image(systemName: "note")
                Text("Notes")
           }
           BlueView()
             .tabItem {
                Image(systemName: "gear")
                Text("Settings")
          }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
