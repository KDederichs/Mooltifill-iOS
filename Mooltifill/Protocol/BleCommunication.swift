//
// Created by Kai Dederichs on 25.02.22.
//

import Foundation
import CoreBluetooth
extension BluetoothService {
    func getStatus() {
        let factory = BleMessageFactory()
        self.peripheral?.writeValue(MooltipassPayload.FLIP_BIT_RESET_PACKET, for: writeCharacteristic!, type: .withoutResponse)
        self.send(packets: factory.serialize(msg: MooltipassMessage(cmd: MooltipassCommand.MOOLTIPASS_STATUS_BLE)))
    }

    private func send(packets: [Data]) {
        print("Send packets")
        for (idx, paket) in packets.enumerated() {
            print("Sending packet")
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

    public func startRead() {
        if (self.readCharacteristic == nil) {
            debugPrint("Attempted to read to device while not connected, aborting")
            return
        }
        peripheral?.readValue(for: readCharacteristic!)
    }

    public func tryParseLocked(data: Data) -> Bool? {
        let factory = BleMessageFactory()
        let payload = factory.deserialize(data: [data])
        if (payload!.cmd == MooltipassCommand.MOOLTIPASS_STATUS_BLE && payload!.data != nil && payload!.data!.count == 5) {
            return payload!.data![0] & 0x4 ==  0x0
        }
        return nil
    }
}