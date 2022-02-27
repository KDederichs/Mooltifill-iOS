//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

extension BluetoothService: CBCentralManagerDelegate {

    var expectedNamePrefix: String { return "Mooltipass BLE" } // 1.

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("bluetooth is OFF (\(central.state.rawValue))")
            disconnect()
        } else {
            print("bluetooth is ON")
            let possibleConnection = checkForConnected();
            if (possibleConnection != nil) {
                debugPrint("Got Peripheral, connecting")
                guard centralManager.state == .poweredOn else {
                    print("bluetooth is off")
                    return
                }
                if (nil == peripheral) {
                    print("No Peripheral")
                    return
                }
                centralManager.connect(peripheral!)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil && peripheral.name?.starts(with: self.expectedNamePrefix) ?? false else { return } // 1.
        print("discovered peripheral: \(peripheral.name!)")

        self.peripheral = peripheral
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let periperalName = peripheral.name {
            print("connected to: \(periperalName)")
        } else {
            print("connected to peripheral")
        }

        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral disconnected")
        self.readCharacteristic = nil
        self.writeCharacteristic = nil
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect: \(error.debugDescription)")
        self.readCharacteristic = nil
        self.writeCharacteristic = nil
    }
}