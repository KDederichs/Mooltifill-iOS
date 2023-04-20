//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
import CoreBluetooth

extension MooltipassBleManager {
    
    public func getStatus() {
        connectToMooltipass {
            self.queueSyncDate()
            self.queueGetStatus()
        }
    }
    
    public func resetFlipBit()
    {
        self.delegate?.debugMessage(message: "[MooltipassBleManager] Resetting FlipBit")
        self.factory.resetFlipBit()
        self.peripheral?.writeValue(self.FLIP_BIT_RESET_PACKET, for: self.writeCharacteristic!, type: .withoutResponse)
    }
    
    public func queueSyncDate() {
        self.delegate?.debugMessage(message: "[MooltipassBleManager] Queing Time Sync")
        self.commandQueue.enqueue {
            let date = Date()
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            
            var bytes = Data(count: 12)
            
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 0, value: UInt16(calendar.component(.year, from: date)))
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 2, value: UInt16(calendar.component(.month, from: date)))
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 4, value: UInt16(calendar.component(.day, from: date)))
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 6, value: UInt16(calendar.component(.hour, from: date)))
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 8, value: UInt16(calendar.component(.minute, from: date)))
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 10, value: UInt16(calendar.component(.second, from: date)))
            
            self.send(packets: self.factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.SET_DATE_BLE, rawData: bytes)))
        }
    }
    
    public func queueGetStatus() {
        self.delegate?.debugMessage(message: "[MooltipassBleManager] Queing Status check")
        self.commandQueue.enqueue {
            self.send(packets: self.factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.MOOLTIPASS_STATUS_BLE)))
        }
    }
    
    public func getCredentials(service: String, login: String?) {
        let cleanedService = service.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")
        let serviceData = _stringToUInt8LEData(input: cleanedService)
        self.delegate?.debugMessage(message: "[MooltipassBleManager] looking up service: \(cleanedService)")
        var loginData : Data? = nil
        if (login != nil) {
            loginData = _stringToUInt8LEData(input: login!)
        }
        connectToMooltipass {
            self._getCredentials(service: serviceData, login: loginData)
        }
    }
    
    public func startRead() {
        if (self.readCharacteristic == nil) {
            debugPrint("Attempted to read to device while not connected, aborting")
            return
        }
        peripheral?.readValue(for: readCharacteristic!)
    }
    
    public func tryParseLocked(message: MooltipassMessage) -> Bool? {
        if (message.data != nil && message.data!.count == 5) {
            return message.data![message.data!.startIndex] & 0x4 ==  0x0
        }
        return nil
    }
    
    public func startFlush() {
        flushing = true
        startRead()
    }
    
    public func getNoteList() {
        connectToMooltipass {
            self._getNoteNode(address: 0)
        }
    }
    
    public func getNoteContent(noteName: String) {
        connectToMooltipass {
            self._getNoteContent(data: self._stringToUInt8LEData(input: noteName))
        }
    }
    
    // Low Level device communication
    public func _getNoteNode(address: UInt16) {
        self.commandQueue.enqueue {
            var bytes = Data(count: 2)
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 0, value: address)
            self.send(packets: self.factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.GET_NOTE_NODE, rawData: bytes)))
        }
    }
    
    public func _getMoreNoteContent() {
        self.commandQueue.enqueue {
            self.send(packets: self.factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.GET_NOTE_CONTENT)))
        }
    }
    
    private func _getNoteContent(data: Data) {
        self.commandQueue.enqueue {
            var bytes = Data(count: data.count + 2)
            BleMessageFactory.arrayCopy(bytes: &bytes, data: data, start: 0)
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: data.count, value: 0)
            self.send(packets: self.factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.GET_NOTE_CONTENT, rawData: bytes)))
        }
    }

    private func _getCredentials(service: Data, login: Data?) {
        self.delegate?.debugMessage(message: "[MooltipassBleManager] Queing Get Credentials")
        self.commandQueue.enqueue {

            let loginOffset = service.count
            let len = loginOffset + (login?.count ?? 0) + 4
            var bytes = Data(count: len)
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 0, value: 0)
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 2, value: login != nil ? UInt16(loginOffset / 2) : 65535)
            BleMessageFactory.arrayCopy(bytes: &bytes, data: service, start: 4)
            if(login != nil) {
                BleMessageFactory.arrayCopy(bytes: &bytes, data: login!, start: 4 + loginOffset)
            }
            self.send(packets: self.factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.GET_CREDENTIAL_BLE, rawData: bytes)))
        }
    }

    public func send(packets: [Data]) {
        for (idx, paket) in packets.enumerated() {
            debugPrint("Sending Packet content: " + hexEncodedString(paket))
            send(packet: paket, readAfter: idx == packets.endIndex - 1)
        }
    }

    private func send(packet: Data, readAfter: Bool = true) {
        if (self.writeCharacteristic == nil) {
            debugPrint("Attempted to write to device while not connected, aborting")
            return
        }
        self.peripheral?.writeValue(packet, for: writeCharacteristic!, type: readAfter ? .withResponse : .withoutResponse)
    }

    private func _stringToUInt8LEData(input: String) -> Data {
        var data = Data(count: input.count * 2)
        let utf16String = Array(input.trimmingCharacters(in: .whitespacesAndNewlines).utf16)
        for (i,c) in utf16String.enumerated() {
            BleMessageFactory.toUInt8LE(bytes: &data, index: i*2, value: UInt16(c))
        }
        return data
    }

    public func _uInt8LEDataToString(data: Data) -> String {
        var uInt16Data = [UInt16](repeating: 0, count: data.count/2)
        for i in stride(from: 0, to: data.count, by: 2) {
            uInt16Data[i/2] = BleMessageFactory.toUInt16(bytes: data, index: i+data.startIndex)
        }
        return String(decoding: uInt16Data, as: UTF16.self)
    }
}
