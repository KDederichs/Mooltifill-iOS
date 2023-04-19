//
//  GetPasswordView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 31.01.23.
//

import SwiftUI
import Combine

struct GetPasswordView: View {
    
    @StateObject private var model = GetCredentialsModel()
    var body: some View {
        NavigationView {
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
                            model.fetchCredentials(service: $model.service.wrappedValue)
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
            }.navigationTitle("Get Password")
        }
    }
}

struct GetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        GetPasswordView()
    }
}
