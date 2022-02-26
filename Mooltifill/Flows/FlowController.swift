//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

class FlowController {
    var currentId: Int = 0
    var readResult: [Data]? = nil

    var bluetoothService: BluetoothService?  = nil

    init(bluetoothService: BluetoothService) {
        self.bluetoothService = bluetoothService
    }
    func bluetoothOn() { }
    func bluetoothOff() { }
    func scanStarted() { }
    func scanStopped() { }
    func connected(peripheral: CBPeripheral) { }
    func disconnected(failure: Bool) { }
    func discoveredPeripheral() { }
    func readyToWrite() { }
    func received(response: Data) {
        // print("received data: \(String(bytes: response, encoding: String.Encoding.ascii) ?? "")")
        let numberOfPackets = (response[1] % 16) + 1
        let id = Int(response[1]) >> 4
        print("Reading package \(id + 1) of \(numberOfPackets) (current ID is \(currentId))")
//        for p in response {
//            print(p)
//        }
//        print("End content")

        if (readResult == nil) {
            readResult = [Data](repeating: Data([0]), count: Int(numberOfPackets))
        }
        if (currentId != id) {
            debugPrint("Received ID \(id) doesn't match with current ID counter \(currentId)")
            resetState()
            return
        }
        readResult![currentId] = response
        if (currentId == numberOfPackets - 1) {
            self.readComplete(data: readResult!)
            resetState()
            return
        } else {
            currentId += 1
            bluetoothService?.startRead()
        }
    }
    func readyToRead() { }
    func writeComplete() { }
    func readComplete(data: [Data]) {}
    func lockedStatus(locked: Bool?) {}

    private func resetState() {
        currentId = 0
        readResult = nil
    }
}