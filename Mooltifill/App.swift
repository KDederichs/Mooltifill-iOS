//
//  AppDelegate.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import SwiftUI

@main
struct AppDelegate: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MooltipassAwareView {
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
        }.onChange(of: scenePhase) { newValue in
            switch newValue {
                case .active:
                    debugPrint("[Lifecyle Event] App becomming active!")
                    break;
                case .background:
                    debugPrint("[Lifecyle Event] App entering BG!")
                    BleManager.shared.dispose()
                    break;
                case .inactive:
                    debugPrint("[Lifecyle Event] App becomming inactive!")
                    BleManager.shared.dispose()
                    break;
                default:
                    break;
            }
        }
    }
}

