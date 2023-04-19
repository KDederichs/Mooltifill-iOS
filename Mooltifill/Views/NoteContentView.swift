//
//  NoteContentView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.04.23.
//

import SwiftUI

struct NoteContentView: View {
    var body: some View {
        VStack {
            Text("Title")
            CopieableValueLable(label: "Note Content", value: "Test")
        }
    }
}

struct NoteContentView_Previews: PreviewProvider {
    static var previews: some View {
        NoteContentView()
    }
}
