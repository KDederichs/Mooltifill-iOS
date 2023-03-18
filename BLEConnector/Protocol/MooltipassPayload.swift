//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
import CoreBluetooth

extension MooltipassBleManager {

    public func getStatus() {
        connectToMooltipass {
            let factory = BleMessageFactory()
            self.peripheral?.writeValue(self.FLIP_BIT_RESET_PACKET, for: self.writeCharacteristic!, type: .withoutResponse)
            self.send(packets: factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.MOOLTIPASS_STATUS_BLE)))
        }
    }

    public func getCredentials(service: String, login: String?) {
        let serviceData = _stringToUInt8LEData(input: service.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: ""))
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

    // Low Level device communication

    private func _getCredentials(service: Data, login: Data?) {
        prepareRead {
            let factory = BleMessageFactory()

            let loginOffset = service.count
            let len = loginOffset + (login?.count ?? 0) + 4
            var bytes = Data(count: len)
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 0, value: 0)
            BleMessageFactory.toUInt8LE(bytes: &bytes, index: 2, value: login != nil ? UInt16(loginOffset / 2) : 65535)
            BleMessageFactory.arrayCopy(bytes: &bytes, data: service, start: 4)
            if(login != nil) {
                BleMessageFactory.arrayCopy(bytes: &bytes, data: login!, start: 4 + loginOffset)
            }
            self.peripheral?.writeValue(self.FLIP_BIT_RESET_PACKET, for: self.writeCharacteristic!, type: .withoutResponse)
            self.send(packets: factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.GET_CREDENTIAL_BLE, rawData: bytes)))
        }
    }

    public func prepareRead(completion: @escaping () -> ()) {
        flushCompleteHandler = completion
        retryCount = 0
        startFlush()
        //completion()
    }

    private func send(packets: [Data]) {
        for (idx, paket) in packets.enumerated() {
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

    private func _uInt8LEDataToString(data: Data) -> String {
        var uInt16Data = [UInt16](repeating: 0, count: data.count/2)
        for i in 0..<data.count {
            uInt16Data[i] = BleMessageFactory.toUInt16(bytes: data, index: i*2)
        }
        return String(decoding: uInt16Data, as: UTF16.self)
    }
}
