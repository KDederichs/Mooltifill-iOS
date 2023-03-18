//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

extension MooltipassBleManager: CBCentralManagerDelegate {

    var expectedNamePrefix: String { return "Mooltipass BLE" } // 1.

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.delegate?.bluetoothChange(state: central.state)
        if central.state != .poweredOn {
            print("bluetooth is OFF (\(central.state.rawValue))")
            bluetoothAvailable = false
            disconnect()
        } else {
            print("bluetooth is ON")
            bluetoothAvailable = true

        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil && peripheral.name?.starts(with: self.expectedNamePrefix) ?? false else { return } // 1.
        print("discovered peripheral: \(peripheral.name!)")

        self.peripheral = peripheral
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let periperalName = peripheral.name {
            print("connected to: \(periperalName)")
        } else {
            print("connected to peripheral")
        }

        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral disconnected")
        self.readCharacteristic = nil
        self.writeCharacteristic = nil
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect: \(error.debugDescription)")
        self.readCharacteristic = nil
        self.writeCharacteristic = nil
        self.delegate?.onError(errorMessage: "Faild to connect to Mooltipass")
    }
}
