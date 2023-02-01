//
//  GetCredentialsModel.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 31.01.23.
//

import Foundation
import Combine

class GetCredentialsModel: ObservableObject
{
    let bleManager = BleManager.shared
    
    @Published var service: String = ""
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var hasCredential = false
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    
    init() {
        bleManager
            .credential
            .map{ credential in return credential.username}
            .receive(on: RunLoop.main)
            .assign(to: \.username, on: self)
            .store(in: &cancellableSet)
        
        bleManager
            .credential
            .map{ credential in return credential.password}
            .receive(on: RunLoop.main)
            .assign(to: \.password, on: self)
            .store(in: &cancellableSet)
        
        bleManager
            .credential
            .map{ credential in return true}
            .receive(on: RunLoop.main)
            .assign(to: \.hasCredential, on: self)
            .store(in: &cancellableSet)
    }
    
}
