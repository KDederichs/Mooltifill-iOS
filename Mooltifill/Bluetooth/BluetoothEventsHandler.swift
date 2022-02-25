//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

extension BluetoothService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        print("services discovered")
        for service in services {
            let serviceUuid = service.uuid.uuidString
            print("discovered service: \(serviceUuid)")

            if serviceUuid == self.commServiceUUID.uuidString {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        print("characteristics discovered")
        for characteristic in characteristics {
            let characteristicUuid = characteristic.uuid.uuidString
            print("discovered characteristic: \(characteristicUuid) | read=\(characteristic.properties.contains(.read)) | write=\(characteristic.properties.contains(.write))")
            if characteristicUuid == self.charWriteUUID.uuidString {
                peripheral.setNotifyValue(true, for: characteristic)

                self.writeCharacteristic = characteristic
                self.flowController?.readyToWrite() // 1.
            }

            if characteristicUuid == self.charReadUUID.uuidString {
                peripheral.setNotifyValue(true, for: characteristic)

                self.readCharacteristic = characteristic
                self.flowController?.readyToRead() // 1.
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            //print("didUpdateValueFor \(characteristic.uuid.uuidString) = count: \(data.count) | \(self.hexEncodedString(data))")
            self.flowController?.received(response: data) // 1.
            self.flowController?.lockedStatus(locked: self.tryParseLocked(data: data))
        } else {
            print("didUpdateValueFor \(characteristic.uuid.uuidString) with no data")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("error while writing value to \(characteristic.uuid.uuidString): \(error.debugDescription)")
        } else {
            print("didWriteValueFor \(characteristic.uuid.uuidString)")
            flowController?.writeComplete()
        }
    }

    private func hexEncodedString(_ data: Data?) -> String {
        let format = "0x%02hhX "
        return data?.map { String(format: format, $0) }.joined() ?? ""
    }
}