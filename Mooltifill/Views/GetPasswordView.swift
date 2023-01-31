//
//  GetPasswordView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 31.01.23.
//

import SwiftUI
import Combine

struct GetPasswordView: View {
    let bleManager = BleManager.shared
    
    @ObservedObject private var model = GetCredentialsModel()
    
    var body: some View {
        VStack {
            TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $model.service)
                .padding()
                .autocapitalization(.none)
                .autocorrectionDisabled()
            Button("Get Credentials") {
                bleManager.bleManager.getCredentials(service: $model.service.wrappedValue, login: nil)
            }

        }.padding()
    }
}

struct GetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        GetPasswordView()
    }
}
