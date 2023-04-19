//
//  MooltipassBleDelegate.swift
//  MooltipassBle
//
//  Created by Kai Dederichs on 12.04.22.
//

import Foundation

public protocol MooltipassBleDelegate : AnyObject {
    func bluetoothChange(enabled: Bool)-> Void
    func onError(errorMessage: String) -> Void
    func lockedStatus(locked: Bool) -> Void
    func credentialNotFound() -> Void
    func credentialsReceived(credential: MooltipassCredential?) -> Void
    func noteListReceived(notes: [String]) -> Void
    func noteContentReceived(content: String) -> Void
    func mooltipassConnected(connected: Bool) -> Void
    func mooltipassReady() -> Void
    func debugMessage(message: String) -> Void
}
