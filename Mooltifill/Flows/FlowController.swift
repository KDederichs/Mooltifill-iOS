//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

protocol FlowController {
    func bluetoothOn()
    func bluetoothOff()
    func scanStarted()
    func scanStopped()
    func connected(peripheral: CBPeripheral)
    func disconnected(failure: Bool)
    func discoveredPeripheral()
    func readyToWrite()
    func received(response: Data)
    func readyToRead()
    func writeComplete()
    func readComplete(data: [Data])
    func lockedStatus(locked: Bool?)
    // TODO: add other events if needed
}

extension FlowController {
    func bluetoothOn() { }
    func bluetoothOff() { }
    func scanStarted() { }
    func scanStopped() { }
    func connected(peripheral: CBPeripheral) { }
    func disconnected(failure: Bool) { }
    func discoveredPeripheral() { }
    func readyToWrite() { }
    func received(response: Data) { }
    func readyToRead() { }
    func writeComplete() { }
    func readComplete(data: [Data]) {}
    func lockedStatus(locked: Bool?) { }
}