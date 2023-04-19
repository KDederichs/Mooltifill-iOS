//
//  AppDelegate.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import SwiftUI

@main
struct AppDelegate: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                GetPasswordView()
                    .tabItem {
                        Label("Get Password", systemImage: "lock")
                    }
                NoteListView()
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }
            }
        }
    }
}

