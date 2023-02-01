//
//  MooltipassAwareView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI
import Combine

struct MooltipassAwareView<Content: View>: ContainerView {
    
    var content: () -> Content
    @ObservedObject private var model = MooltipassAwareModel()
    
    var body: some View {
        if (model.isLocked) {
            VStack {
                Image("Lock")
                Text("Mooltipass is locked, please unlock")
            }
        } else {
            content()
        }
    }
}

struct MooltipassAwareView_Previews: PreviewProvider {
    static var previews: some View {
        MooltipassAwareView {
            GetPasswordView()
        }
    }
}
