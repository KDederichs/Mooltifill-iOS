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
                Form {
                    Section("Website") {
                        TextField("URL", text: $model.service)
                            .padding()
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    Section {
                        Button("Get Credentials") {
                            bleManager.fetchCredential(service: $model.service.wrappedValue, login: nil)
                        }
                        .disabled(
                            $model.service.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || $model.isLoading.wrappedValue
                        )
                    }
                    if (model.isLoading) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    if (model.hasCredential) {
                        Section("Credentials") {
                            CopieableValueLable(label: "Username", value: model.username)
                            CopieableValueLable(label: "Password", value: model.password)
                        }
                    }
                }
        }
    }
}

struct GetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        GetPasswordView()
    }
}
