//
//  MooltipassAwareModel.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import Foundation
import Combine

class MooltipassAwareModel: ObservableObject
{
    let bleManager = BleManager.shared
    
    
    @Published var isLocked = false
    @Published var isConnected = true
    @Published var bluetoothEnabled = true
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        bleManager
            .locked
            .receive(on: RunLoop.main)
            .assign(to: \.isLocked, on: self)
            .store(in: &cancellableSet)
        
        bleManager
            .isMooltipassConnected
            .receive(on: RunLoop.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellableSet)
        
        bleManager
            .bluetoothEnabled
            .receive(on: RunLoop.main)
            .assign(to: \.bluetoothEnabled, on: self)
            .store(in: &cancellableSet)
    }
}
