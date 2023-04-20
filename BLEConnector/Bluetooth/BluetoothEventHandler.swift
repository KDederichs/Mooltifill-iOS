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
                self.resetFlipBit()
                if (connectedCallback != nil) {
                    connectedCallback!()
                    connectedCallback = nil
                    self.delegate?.debugMessage(message: "[MooltipassBleManager] CALLING START FLUSH FROM peripheral")
                    self.startFlush()
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
                    if !self.commandQueue.isEmpty {
                        self.delegate?.debugMessage(message: "[MooltipassBleManager] Peeking from Flush")
                        commandQueue.peek!()
                    } else {
                        self.delegate?.debugMessage(message: "[MooltipassBleManager] Queue is empty, nothing to execute.")
                    }
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

    public func hexEncodedString(_ data: Data?) -> String {
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
            resetState()
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
            break
        case .PLEASE_RETRY_BLE:
            if (retryCount < 10) {
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Retrying operation")
                debugPrint("Retrying operation")
                retryCount += 1
                self.resetState(clearRetryCount: false)
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Peeking from Retry")
                self.commandQueue.peek?()
            } else {
                resetState()
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Retry limit exceeded, abort.")
                self.delegate?.onError(errorMessage: "Could not read from Mooltipass")
            }
            break
        case .SET_DATE_BLE:
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Set Time Result: " + hexEncodedString(message!.data))
            resetState()
            break
        case .GET_NOTE_NODE:
            resetState()
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Note Node Data: " + hexEncodedString(message!.data))
            let noteName = _uInt8LEDataToString(data: message!.data!.dropFirst(2).dropLast(2))
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Note Node Data: " + noteName)
            self.delegate?.noteListReceived(notes: Array(noteNames))
            if (BleMessageFactory.toUInt16(bytes: message!.data!, index: message!.data!.startIndex) > 0) {
                noteNames.insert(noteName)
                self._getNoteNode(address: BleMessageFactory.toUInt16(bytes: message!.data!, index: message!.data!.startIndex))
                self.commandQueue.peek!()
            }
            break
        case .GET_NOTE_CONTENT:
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Note Node Content Data: " + hexEncodedString(message!.data))
            let textPayload = message!.data!.dropFirst(4)
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Text Payload Length: \(textPayload.count)")
            self.noteContent += hexStringtoAscii(hexEncodedString(message!.data!.dropFirst(4)))
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Note Node Content Data Decoded: " + self.noteContent)
            if (textPayload.count < 512) {
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Note is done")
                self.delegate?.noteContentReceived(content: self.noteContent)
                resetState()
            } else {
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Note is still ongoing, fetching more")
                self._getMoreNoteContent()
                resetState()
            }

            break
        default:
            resetState()
            break
        }
    }
    
    func hexStringtoAscii(_ hexString : String) -> String {

        let pattern = "(0x)?([0-9a-f]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = hexString as NSString
        let matches = regex.matches(in: hexString, options: [], range: NSMakeRange(0, nsString.length))
        let characters = matches.map {
            Character(UnicodeScalar(UInt32(nsString.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        return String(characters)
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

    private func resetState(clearRetryCount: Bool = true, keepId: Bool = false) {
        if (!keepId) {
            currentId = 0
        }
        if (clearRetryCount) {
            retryCount = 0
        }
        readResult = nil
        
        if (clearRetryCount) {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Removing command from queue.")
            self.commandQueue.dequeue()
            if !self.commandQueue.isEmpty {
                self.delegate?.isLoading(loading: true)
                self.delegate?.debugMessage(message: "[MooltipassBleManager] Running next command in queue")
                commandQueue.peek!()
            } else {
                self.noteContent = ""
                self.delegate?.isLoading(loading: false)
            }
        }
    }
}
