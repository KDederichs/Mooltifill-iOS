//
//  NoteListView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.04.23.
//

import SwiftUI
import Combine

struct NoteListView: View {
    @ObservedObject private var model = NoteListModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(model.notes) { note in
                        NavigationLink(destination: NoteContentView(noteName: note.name)) {
                            Text(note.name)
                        }
                    }
                }.refreshable {
                    model.getNoteList()
                }.overlay {
                    Group {
                        if (model.isLoading) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else if ($model.notes.wrappedValue.isEmpty) {
                            Text("Looks like you have no notes or they are not yet loaded :)")
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.automatic)
            .onFirstAppear {
                model.getNoteList()
            }
        }
    }
}

struct NoteListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteListView()
    }
}
