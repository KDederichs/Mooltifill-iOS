//
//  NoteContentView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.04.23.
//

import SwiftUI

struct NoteContentView: View {
    @StateObject private var model = NoteContentModel()
    var noteName: String
    var body: some View {
        NavigationView {
            VStack {
                if(model.isLoading) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text(model.content)
                        .textSelection(.enabled)
                    if (!$model.content.wrappedValue.isEmpty) {
                        Button(action:{
                            UIPasteboard.general.string = $model.content.wrappedValue
                        }) {
                            HStack {
                                Text("Copy")
                                Image(systemName: "doc.on.doc")
                            }
                        }.padding(.top)
                    }
                }
            }
            .navigationTitle(noteName)
            .navigationBarTitleDisplayMode(.inline)
            .onFirstAppear {
                model.fetchNote(noteName: noteName)
            }
        }
    }
}

struct NoteContentView_Previews: PreviewProvider {
    static var previews: some View {
        NoteContentView(noteName: "Test")
    }
}
