//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
class MooltipassPayload: NSObject {
    public static let FLIP_BIT_RESET_PACKET = Data([0xFF, 0xFF])

    public static func getCredentials(service: Data, login: Data?) -> Data {
        let loginOffset = service.count
        let len = loginOffset + (login?.count ?? 0) + 4
        var bytes = Data(count: len)
        BleMessageFactory.toUInt8LE(bytes: &bytes, index: 0, value: 0)
        BleMessageFactory.toUInt8LE(bytes: &bytes, index: 2, value: login != nil ? UInt16(loginOffset / 2) : 65535)
        BleMessageFactory.arrayCopy(bytes: &bytes, data: service, start: 4)
        if(login != nil) {
            BleMessageFactory.arrayCopy(bytes: &bytes, data: login!, start: 4 + loginOffset)
        }
        debugPrint("%%%%%Get Credentials Start")
        for p in bytes {
            debugPrint(String(p))
        }
        debugPrint("%%%%%Get Credentials end")
        return bytes
    }

    public static func getCredentials(service: String, login: String?) -> Data {
        let serviceData = stringToUInt8LEData(input: service)
        var loginData : Data? = nil
        if (login != nil) {
            loginData = stringToUInt8LEData(input: login!)
        }
        return getCredentials(service: serviceData, login: loginData)
    }

    public static func stringToUInt8LEData(input: String) -> Data {
        var data = Data(count: input.count * 2)
        let utf16String = Array(input.trimmingCharacters(in: .whitespacesAndNewlines).utf16)
        for (i,c) in utf16String.enumerated() {
            BleMessageFactory.toUInt8LE(bytes: &data, index: i*2, value: UInt16(c))
        }
        return data
    }

    public static func uInt8LEDataToString(data: Data) -> String {
        var uInt16Data = [UInt16](repeating: 0, count: data.count/2)
        for i in 0..<data.count {
            uInt16Data[i] = BleMessageFactory.toUInt16(bytes: data, index: i*2)
        }
        return String(decoding: uInt16Data, as: UTF16.self)
    }
}