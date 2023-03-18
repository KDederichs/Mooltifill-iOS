//
// Created by Kai Dederichs on 19.02.22.
//

import CoreBluetooth

public class BleMessageFactory: MessageFactory {

    let HID_HEADER_SIZE = 2
    let PACKET_CMD_OFFSET = 0
    let PACKET_LEN_OFFSET = 2
    let PACKET_DATA_OFFSET = 4
    let LAST_MESSAGE_ACK_FLAG = 0x40
    let HID_PACKET_SIZE = 64
    let HID_PACKET_DATA_PAYLOAD = 62 // HID_PACKET_SIZE - HID_HEADER_SIZE
    let MP_PACKET_DATA_PAYLOAD = 58 // HID_PACKET_DATA_PAYLOAD - PACKET_DATA_OFFSET

    var flip = false

    public static func toUInt8LE(bytes: inout Data, index: Int, value: UInt16) {
        bytes[index] = UInt8(value & 0xFF)
        bytes[index + 1] = UInt8((value & 0xFF00) >> 8)
    }

    public static func toUInt16(bytes: Data, index: Int) -> UInt16 {
       (UInt16(CFSwapInt16LittleToHost(UInt16(bytes[index])) | (CFSwapInt16LittleToHost(UInt16(bytes[index + 1])) << 8)))
    }

    public static func strLenUtf16(bytes: Data) -> Int? {
        for index in stride(from: bytes.startIndex, to: bytes.endIndex, by: 2) {
            if(toUInt16(bytes: bytes, index: index) == 0) {
                return index
            }
        }
        return nil
    }

    public static func chunks(bytes: Data?, chunkSize: Int) -> [Data] {
        if (nil == bytes) {
            print("Chunk bytes nil")
            return [Data([0])]
        }
        return stride(from: 0, to: bytes!.count, by: chunkSize).map {
            Data(bytes![$0..<min($0 + chunkSize, bytes!.count)])
        }
    }

    public static func arrayCopy(bytes: inout Data, data: Data, start: Int) {
        for i in 0...(data.count - 1) {
            bytes[i + start] = data[i]
        }
    }

    func deserialize(data: [Data], debug: Bool = true) -> MooltipassMessage? {
        let numberOfPackets = (data[0][1] % 16) + 1
        if (numberOfPackets != data.count) {
            if (debug) {
                print("Wrong number of reported packages \(numberOfPackets) expected \(data.count)")
                print(data)
            }
            return nil
        }
        let len = BleMessageFactory.toUInt16(bytes: data[0], index: HID_HEADER_SIZE + PACKET_LEN_OFFSET)
        let cmdInt = BleMessageFactory.toUInt16(bytes: data[0], index: HID_HEADER_SIZE + PACKET_CMD_OFFSET)
        let hidPayload = data.reduce(Data()) {
            $0 + $1[2...63]
        }
        if (len > hidPayload.count - PACKET_DATA_OFFSET) {
            print("Not enough data for reported length \(len) got \(hidPayload.count - PACKET_DATA_OFFSET)")
            return nil
        }
//        print("%%%%%%%")
//        print(cmdInt)
        let cmd = MooltipassCommand(rawValue: cmdInt)
        if(cmd != nil) {
            let d = hidPayload[PACKET_DATA_OFFSET..<(Int(len) + PACKET_DATA_OFFSET)]
            return MooltipassMessage(cmd: cmd!, rawData: d)
        }
        return nil
    }

    func serialize(msg: MooltipassMessage) -> [Data] {
        let len = msg.data?.count ?? 0
        let ack = 0x00
        let flipBit = flip ? 0x80 : 0x00
//        print("Flip Bit: \(flipBit)")
//        print("Len: \(len)")
        flip = !flip
        var hidPayload = Data(count: len + PACKET_DATA_OFFSET)
        BleMessageFactory.toUInt8LE(bytes: &hidPayload, index: PACKET_CMD_OFFSET, value: msg.cmd.rawValue)
        BleMessageFactory.toUInt8LE(bytes: &hidPayload, index: PACKET_LEN_OFFSET, value: UInt16(len))
        if (msg.data != nil) {
            BleMessageFactory.arrayCopy(bytes: &hidPayload, data: msg.data!, start: PACKET_DATA_OFFSET)
        }


//        debugPrint("%%%%%%%%% HID Payload%%%%%%%%")
//        for p in hidPayload {
//            debugPrint(String(p))
//        }
//        debugPrint("%%%%%%%%% HID Payload end %%%%%%%%%%%%")

        let chunks = BleMessageFactory.chunks(bytes: hidPayload, chunkSize: HID_PACKET_DATA_PAYLOAD)
//        print("Chunk count: \(chunks.count)")
        let numberOfPackets = chunks.count
        var ret = [Data](repeating: Data([0]), count: chunks.count)
        var i = 0
        for chunk in chunks {
            var bytes: Data = Data(count: HID_PACKET_SIZE)
//            debugPrint("chunk size \(chunk.count)")
            bytes[0] = UInt8(flipBit + ack + chunk.count)
            bytes[1] = UInt8((i << 4) + (numberOfPackets - 1))
            BleMessageFactory.arrayCopy(bytes: &bytes, data: chunk, start: HID_HEADER_SIZE)
            ret[i] = bytes
            print(bytes.count)
            i = i + 1
        }
//        print("Ret length")
//        print(ret.count)

        return ret
    }
}
