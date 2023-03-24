//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

extension MooltipassBleManager: CBPeripheralDelegate {

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        self.delegate?.debugMessage(message: "[MooltipassBleManager] Services discovered")
        for service in services {
            let serviceUuid = service.uuid.uuidString
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Discovered service \(serviceUuid)")

            if serviceUuid == self.commServiceUUID.uuidString {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        self.delegate?.debugMessage(message: "[MooltipassBleManager] Characteristics discovered")
        for characteristic in characteristics {
            let characteristicUuid = characteristic.uuid.uuidString
            self.delegate?.debugMessage(message: "[MooltipassBleManager] discovered characteristic: \(characteristicUuid) | read=\(characteristic.properties.contains(.read)) | write=\(characteristic.properties.contains(.write))")
            if characteristicUuid == self.charWriteUUID.uuidString {
                peripheral.setNotifyValue(true, for: characteristic)

                self.writeCharacteristic = characteristic
                writeConnected = true
            }

            if characteristicUuid == self.charReadUUID.uuidString {
                peripheral.setNotifyValue(true, for: characteristic)

                self.readCharacteristic = characteristic
                readConnected = true
            }
            if (readConnected && writeConnected) {
                self.delegate?.mooltipassReady()
                if (connectedCallback != nil) {
                    connectedCallback!()
                    connectedCallback = nil
                }
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            if (flushing) {
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Flushing Data start")
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Flush value: \(hexEncodedString(data))")
                if (flushData == nil || !data.elementsEqual(flushData!))
                {
                    self.delegate?.debugMessage(message: "[MooltipassBleManager] Flushing continues")
                    flushData = data
                    self.startRead()
                } else {
                    self.delegate?.debugMessage(message: "[MooltipassBleManager] Flushing complete")
                    flushing = false
                    flushData = nil
                    self.flushCompleteHandler()
                }
            } else {
                let numberOfPackets = (data[1] % 16) + 1
                let id = Int(data[1]) >> 4
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Package \(id+1) of \(numberOfPackets): \(hexEncodedString(data))")
                if (currentId == id) {
                    if (readResult == nil) {
                        readResult = [Data](repeating: Data([0]), count: Int(numberOfPackets))
                    }
                    readResult![currentId] = data
                    currentId += 1
                    if (id != numberOfPackets - 1) {
                        self.delegate?.debugMessage(message: "[MooltipassBleManager] Package is not end package, should read more. (\(currentId) of \(id+1))")
                        //startRead()
                    } else {
                        self.delegate?.debugMessage(message: "[MooltipassBleManager] Read complete, parsing result")
                        handleResult()
                        resetState()
                    }
                } else {
                    self.delegate?.debugMessage(message: "[MooltipassBleManager] Current Id \(currentId) doesn't match \(id+1), skipping")
                }
            }
        } else {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Read on \(characteristic.uuid.uuidString) returned no data.")
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Error while writing value to \(characteristic.uuid.uuidString): \(error.debugDescription)")
        } else {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Wrote value to \(characteristic.uuid.uuidString)")
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
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Result could not be parsed!")
            resetState()
            return
        }

        switch (message!.cmd) {
        case .MOOLTIPASS_STATUS_BLE:
            deviceLocked = tryParseLocked(message: message!)
            self.delegate?.lockedStatus(locked: (deviceLocked == true))
            resetState()
            break
        case .GET_CREDENTIAL_BLE:
            if (message?.data != nil && message!.data!.count > 0) {
                let username = parseCredentialsPart(idx: 0, data: message!.data!)
                let password = parseCredentialsPart(idx: 6, data: message!.data!)
                if (username != nil && password != nil) {
                    self.delegate?.credentialsReceived(credential: MooltipassCredential(username: username!, password: password!))
                } else {
                    self.delegate?.onError(errorMessage: "Error decoding credentials")
                }
            } else if(message?.data != nil && message!.data!.count == 0) {
                self.delegate?.credentialNotFound()
            }
            resetState()
            break
        case .PLEASE_RETRY_BLE:
            if (retryCount < 10) {
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Retrying operation")
                debugPrint("Retrying operation")
                retryCount += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.resetState()
                    self.prepareRead(completion: self.flushCompleteHandler)
                    //self.flushCompleteHandler()
                    //self.startRead()
                }
            } else {
                resetState()
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Retry limit exceeded, abort.")
                self.delegate?.onError(errorMessage: "Could not read from Mooltipass")
            }
            break
        default:
            resetState()
            break
        }
    }

    private func parseCredentialsPart(idx: Int, data: Data) -> String? {
        let offset = Int(BleMessageFactory.toUInt16(bytes: data, index: idx + data.startIndex)) * 2 + data.startIndex + 8
        let slice = data[Int(offset)..<data.endIndex]
        let partLength = BleMessageFactory.strLenUtf16(bytes: slice)
        if (partLength != nil) {
            return String(bytes: slice[slice.startIndex..<Int(partLength!)], encoding: String.Encoding.utf16LittleEndian)
        }
        return nil
    }

    private func resetState(clearRetryCount: Bool = true) {
        currentId = 0
        if (clearRetryCount) {
            retryCount = 0
        }
        readResult = nil
    }
}
