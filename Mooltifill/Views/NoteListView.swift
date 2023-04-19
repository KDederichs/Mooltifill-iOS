//
//  NoteListView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.04.23.
//

import SwiftUI
import Combine

struct NoteListView: View {
    let bleManager = BleManager.shared
    
    @ObservedObject private var model = NoteListModel()
    
    var body: some View {
        MooltipassAwareView {
            VStack {
                List(model.notes) {
                    Text($0.name)
                }.refreshable {
                    bleManager.getNoteList()
                }
            }
        }
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteListView()
    }
}
