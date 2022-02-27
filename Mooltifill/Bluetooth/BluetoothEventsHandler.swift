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
            }

            if characteristicUuid == self.charReadUUID.uuidString {
                peripheral.setNotifyValue(true, for: characteristic)

                self.readCharacteristic = characteristic
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            if (flushing) {
                if (flushData == nil) {
                    flushData = data;
                    debugPrint("Flush: Read for nil Data")
                    startRead()
                } else {
                    if (!flushData!.elementsEqual(data)) {
                        flushData = data
                        debugPrint("Flush: Read for missmatch")
                        startRead()
                    } else {
                        debugPrint("Flush complete")
                        flushing = false
                        flushData = nil
                        resetState()
                        flushCompleteHandler()
                    }
                }
            } else {
                //print("didUpdateValueFor \(characteristic.uuid.uuidString) = count: \(data.count) | \(self.hexEncodedString(data))")
                let numberOfPackets = (data[1] % 16) + 1
                let id = Int(data[1]) >> 4
                print("Reading package \(id + 1) of \(numberOfPackets) (current ID is \(currentId))")
                debugPrint(hexEncodedString(data))

                if (readResult == nil) {
                    readResult = [Data](repeating: Data([0]), count: Int(numberOfPackets))
                }
                if (currentId != id) {
                    debugPrint("Received ID \(id) doesn't match with current ID counter \(currentId)")
                    resetState()
                    return
                }
                readResult![currentId] = data
                if (currentId == numberOfPackets - 1) {
                    handleResult()
                    resetState()
                    return
                } else {
                    currentId += 1
                    startRead()
                }
            }
        } else {
            print("didUpdateValueFor \(characteristic.uuid.uuidString) with no data")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("error while writing value to \(characteristic.uuid.uuidString): \(error.debugDescription)")
        } else {
            print("didWriteValueFor \(characteristic.uuid.uuidString)")
            startRead()
        }
    }

    private func hexEncodedString(_ data: Data?) -> String {
        let format = "0x%02hhX "
        return data?.map { String(format: format, $0) }.joined() ?? ""
    }

    private func handleResult() {
        let factory = BleMessageFactory()
        let message = factory.deserialize(data: readResult!)
        if (message == nil) {
            debugPrint("Result could not be parsed!")
            resetState()
            return
        }

        switch (message!.cmd) {
        case .MOOLTIPASS_STATUS_BLE:
            deviceLocked = tryParseLocked(message: message!)
            break
        case .GET_CREDENTIAL_BLE:
            if (message?.data != nil && message!.data!.count > 0) {
                debugPrint(hexEncodedString(message!.data!))
                debugPrint("Login \(parseCredentialsPart(idx: 0, data: message!.data!))")
                debugPrint("Description \(parseCredentialsPart(idx: 2, data: message!.data!))")
                debugPrint("Third \(parseCredentialsPart(idx: 4, data: message!.data!))")
                debugPrint("Password \(parseCredentialsPart(idx: 6, data: message!.data!))")
            }
            break
        case .PLEASE_RETRY_BLE:
            debugPrint("Retrying operation")
            flushRead(completion: flushCompleteHandler)
            break
        default:
            break
        }

        resetState()
    }

    private func parseCredentialsPart(idx: Int, data: Data) -> String? {
        print("Idx \(idx)")
        print("UInt16 \(BleMessageFactory.toUInt16(bytes: data, index: idx + data.startIndex))")
        let offset = Int(BleMessageFactory.toUInt16(bytes: data, index: idx + data.startIndex)) * 2 + data.startIndex + 8
        print("Offset \(offset)")
        let slice = data[Int(offset)..<data.endIndex]
        print("Slice Start Idx \(slice.startIndex)")
        let partLength = BleMessageFactory.strLenUtf16(bytes: slice)
        if (partLength != nil) {
            print("Part Length \(partLength!)")
            return String(bytes: slice[slice.startIndex..<Int(partLength!)], encoding: String.Encoding.utf16LittleEndian)
        }
        return nil
    }

    private func resetState() {
        currentId = 0
        readResult = nil
    }
}