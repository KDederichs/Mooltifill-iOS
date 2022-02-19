//
// Created by Kai Dederichs on 19.02.22.
//

import CoreBluetooth

protocol UIntToBytesConvertable {
    var toBytes: [UInt8] { get }
}

extension UIntToBytesConvertable {
    func toByteArr<T: BinaryInteger>(endian: T, count: Int) -> [UInt8] {
        var _endian = endian
        let bytePtr = withUnsafePointer(to: &_endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return [UInt8](bytePtr)
    }
}

extension UInt16: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
            return toByteArr(endian: self.littleEndian,
                    count: MemoryLayout<UInt16>.size)
        } else {
            return toByteArr(endian: self.bigEndian,
                    count: MemoryLayout<UInt16>.size)
        }
    }
}

extension Array{

    func forEachWithIndex(_ callback: (Int, Element) -> ()){

        for (index, element) in self.enumerated(){
            callback(index, element)
        }
    }
}

class BleMessageFactory: MessageFactory {

    static let HID_HEADER_SIZE = 2
    static let PACKET_CMD_OFFSET = 0
    static let PACKET_LEN_OFFSET = 2
    static let PACKET_DATA_OFFSET = 4
    static let LAST_MESSAGE_ACK_FLAG = 0x40
    static let HID_PACKET_SIZE = 64
    static let HID_PACKET_DATA_PAYLOAD = HID_PACKET_SIZE - HID_HEADER_SIZE
    static let MP_PACKET_DATA_PAYLOAD = HID_PACKET_DATA_PAYLOAD - PACKET_DATA_OFFSET

    var flip = false

    public static func setShort(bytes: inout Data, index: Int, value: UInt16) {
        let newBytes = value.toBytes
        bytes[index] = newBytes[0]
        bytes[index + 1] = newBytes[1]
    }

    public static func getShort(bytes: Data, index: Int) -> UInt16 {
        let byteArray = [bytes[index], ((bytes[index + 1]))]
        return  byteArray.withUnsafeBytes { $0.load(as: UInt16.self) }
    }

    public static func strLenUtf16(bytes: Data) -> Int? {
        for index in stride(from: 0, to: bytes.count, by: 2) {
            if(getShort(bytes: bytes, index: index) == 0) {
                return index
            }
        }
        return nil
    }

    public static func chunks(bytes: Data?, chunkSize: Int) -> [Data] {
        if (nil == bytes) {
            return [Data([0])]
        }
        return stride(from: 0, to: ((bytes!.count - 1) / chunkSize), by: 1).map {
            bytes![$0 * chunkSize...min(bytes!.count, ($0 + 1) * chunkSize)]
        }
    }

    func deserialize(data: [Data]) -> MooltipassMessage? {
        let numberOfPackets = (data[0][1] % 16) + 1
//        if (numberOfPackets != data.count) {
//            print("Wrong number of reported packages \(numberOfPackets) expected \(data.count)")
//            print(data)
//            return nil
//        }
        let len = BleMessageFactory.getShort(bytes: data[0], index: BleMessageFactory.HID_HEADER_SIZE + BleMessageFactory.PACKET_LEN_OFFSET)
        let cmdInt = BleMessageFactory.getShort(bytes: data[0], index: BleMessageFactory.HID_HEADER_SIZE + BleMessageFactory.PACKET_CMD_OFFSET)
        let hidPayload = data.reduce(Data([0])) {
            $0 + $1[2...63]
        }
//        if (len > hidPayload.count - BleMessageFactory.PACKET_DATA_OFFSET) {
//            print("Not enough data for reported length \(len) got \(hidPayload.count - BleMessageFactory.PACKET_DATA_OFFSET)")
//            return nil
//        }
        print(cmdInt)
        let cmd = MooltipassCommand(rawValue: cmdInt)
        if(cmd != nil) {
            let d = hidPayload[BleMessageFactory.PACKET_DATA_OFFSET...(Int(len) + BleMessageFactory.PACKET_DATA_OFFSET)]
            return MooltipassMessage(cmd: cmd!, rawData: d)
        }
        return nil
    }

    func serialize(msg: MooltipassMessage) -> [Data] {
        let len = msg.data?.count ?? 0
        let ack = 0x00
        let flipBit = flip ? 0x80 : 0x00
        flip = !flip
        var hidPayload = Data(count: len)
        BleMessageFactory.setShort(bytes: &hidPayload, index: BleMessageFactory.PACKET_CMD_OFFSET, value: msg.cmd.rawValue)
        BleMessageFactory.setShort(bytes: &hidPayload, index: BleMessageFactory.PACKET_LEN_OFFSET, value: UInt16(len))
        hidPayload.insert(contentsOf: msg.data!, at: BleMessageFactory.PACKET_DATA_OFFSET)
        let chunks = BleMessageFactory.chunks(bytes: hidPayload, chunkSize: BleMessageFactory.HID_PACKET_DATA_PAYLOAD)
        let numberOfPackets = chunks.count
        var ret = [Data]()
        var i = 0
        for chunk in chunks {
            var bytes: Data = Data(count: BleMessageFactory.HID_PACKET_SIZE)
            bytes[0] = UInt8(flipBit + ack + chunk.count)
            bytes[1] = UInt8((i << 4) + (numberOfPackets - 1))
            bytes.insert(contentsOf: chunk, at: BleMessageFactory.HID_HEADER_SIZE)
            ret[i] = bytes
            i = i + 1
        }
        return ret
    }
}
