//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

class PairingFlow {

    let timeout = 15.0
    var waitForPeripheralHandler: () -> Void = { }
    var pairingHandler: (Bool) -> Void = { _ in }
    var pairingWorkitem: DispatchWorkItem?
    var pairing = false
    var currentId = 0
    var readResult: [Data]?
    var a: Data?

    weak var bluetoothService: BluetoothService?

    init(bluetoothService: BluetoothService) {
        self.bluetoothService = bluetoothService
    }

    // MARK: Pairing steps

    func waitForPeripheral(completion: @escaping () -> Void) {
        self.pairing = false
        self.pairingHandler = { _ in }

        let possibleConnection = bluetoothService?.checkForConnected();
        if (possibleConnection != nil) {
            completion()
            return
        }

        self.bluetoothService?.startScan()
        self.waitForPeripheralHandler = completion
    }

    func checkForConnected() {
    }

    func pair(completion: @escaping (Bool) -> Void) {
        guard self.bluetoothService?.centralManager.state == .poweredOn else {
            print("bluetooth is off")
            self.pairingFailed()
            return
        }
        guard let peripheral = self.bluetoothService?.peripheral else {
            print("peripheral not found")
            self.pairingFailed()
            return
        }

        self.pairing = true
        self.pairingWorkitem = DispatchWorkItem { // 2.
            print("pairing timed out")
            self.pairingFailed()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + self.timeout, execute: self.pairingWorkitem!) // 2.

        print("pairing...")
        self.pairingHandler = completion
        self.bluetoothService?.centralManager.connect(peripheral)
    }

    func cancel() {
        self.bluetoothService?.stopScan()
        self.bluetoothService?.disconnect()
        self.pairingWorkitem?.cancel()

        self.pairing = false
        self.pairingHandler = { _ in }
        self.waitForPeripheralHandler = { }
    }

    private func pairingFailed() {
        self.pairingHandler(false)
        self.cancel()
    }
}

// MARK: 3. State handling
extension PairingFlow: FlowController {
    func discoveredPeripheral() {
        self.bluetoothService?.stopScan()
        self.waitForPeripheralHandler()
    }

    func readyToWrite() {
        guard self.pairing else { return }

        self.bluetoothService?.getStatus() // 4.
        //bluetoothService?.startRead()
    }

    func writeComplete() {
        bluetoothService?.startRead()
    }

    func received(response: Data) {
        // print("received data: \(String(bytes: response, encoding: String.Encoding.ascii) ?? "")")
        let numberOfPackets = (response[1] % 16) + 1
        debugPrint("NOP \(numberOfPackets)")

        let id = Int(response[1]) >> 4
        readResult = [Data](repeating: Data([0]), count: Int(numberOfPackets))

        if (currentId != id) {
            debugPrint("Received ID \(id) doesn't match with current ID counter \(currentId)")
            return
        }
        readResult![Int(id)] = response
        if (currentId == numberOfPackets - 1) {
            self.pairingHandler(true)
            self.cancel()
            readComplete(data: readResult!)
        } else {
            currentId += 1
            bluetoothService?.startRead()
        }

//        if (a == nil) {
//            a =  response
//            bluetoothService?.startRead()
//        } else {
//            if (!a!.elementsEqual(response)) {
//                bluetoothService?.startRead()
//            } else {
//                debugPrint("Flush complere")
//            }
//        }
    }

    func readComplete(data: [Data]) {
        let factory = BleMessageFactory()
        let message = factory.deserialize(data: data)
        if (message?.cmd != MooltipassCommand.MOOLTIPASS_STATUS_BLE) {
            debugPrint("Response is not a Status response")
            return
        }

        for p in message!.data! {
            debugPrint(p)
        }
        debugPrint(message?.dataAsString() ?? "Deserialisation failed")
    }

    func disconnected(failure: Bool) {
        self.pairingFailed()
    }

    func lockedStatus(locked: Bool?) {
        debugPrint("Locked? \(locked)")
    }

    func bluetoothOn() {
        debugPrint("Initialise Pairing connection")
        self.waitForPeripheral {
            debugPrint("Attempting connection")
            self.pair { result in
                debugPrint("Status: pairing \(result ? "successful" : "failed")")
            }
        }
    }
}