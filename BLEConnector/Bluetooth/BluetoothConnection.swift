//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

extension MooltipassBleManager: CBCentralManagerDelegate {

    var expectedNamePrefix: String { return "Mooltipass BLE" } // 1.

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.delegate?.bluetoothChange(enabled: (central.state.rawValue != 0))
        if central.state != .poweredOn {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Bluetooth is off")
            bluetoothAvailable = false
            disconnect()
        } else {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Bluetooth is on")
            bluetoothAvailable = true
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil && peripheral.name?.starts(with: self.expectedNamePrefix) ?? false else { return } // 1.
        self.delegate?.debugMessage(message: "[MooltipassBleManager] discovered peripheral: \(peripheral.name!)")
        self.peripheral = peripheral
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let periperalName = peripheral.name {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] connected to: \(periperalName)")
        } else {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] connected to: peripheral")
        }

        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.delegate?.debugMessage(message: "[MooltipassBleManager] peripheral disconnected")
        self.readCharacteristic = nil
        self.writeCharacteristic = nil
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.delegate?.debugMessage(message: "[MooltipassBleManager] failed to connect: \(error.debugDescription)")
        self.readCharacteristic = nil
        self.writeCharacteristic = nil
        self.delegate?.onError(errorMessage: "Faild to connect to Mooltipass")
    }
}
