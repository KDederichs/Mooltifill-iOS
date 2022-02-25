//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

class PairingFlow: FlowController {

    let timeout = 15.0
    var waitForPeripheralHandler: () -> Void = { }
    var pairingHandler: (Bool) -> Void = { _ in }
    var pairingWorkitem: DispatchWorkItem?
    var pairing = false
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

    override func discoveredPeripheral() {
        self.bluetoothService?.stopScan()
        self.waitForPeripheralHandler()
    }

    override func readyToWrite() {
        guard self.pairing else { return }

        self.bluetoothService?.getStatus() // 4.
        //bluetoothService?.startRead()
    }

    override func writeComplete() {
        bluetoothService?.startRead()
    }

    override func readComplete(data: [Data]) {
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
        self.pairingHandler(true)
        // self.cancel()
    }

    override func disconnected(failure: Bool) {
        self.pairingFailed()
    }

    override func lockedStatus(locked: Bool?) {
        debugPrint("Locked? \(locked)")
    }

    override func bluetoothOn() {
        debugPrint("Initialise Pairing connection")
        self.waitForPeripheral {
            debugPrint("Attempting connection")
            self.pair { result in
                debugPrint("Status: pairing \(result ? "successful" : "failed")")
            }
        }
    }
}
