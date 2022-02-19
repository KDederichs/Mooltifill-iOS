//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
class MooltipassPayload: NSObject {
    public static func getCredentials(service: Data, login: Data?) -> Data {
        let loginOffset = service.count
        let len = loginOffset + (login?.count ?? 0) + 4
        var bytes = Data(count: len)
        BleMessageFactory.setShort(bytes: &bytes, index: 0, value: 0)
        BleMessageFactory.setShort(bytes: &bytes, index: 2, value: login != nil ? UInt16(loginOffset / 2) : 65535)
        bytes.insert(contentsOf: service, at: 4)
        if(login != nil) {
            bytes.insert(contentsOf: service, at: 4 + loginOffset)
        }
        return bytes
    }

    public static func getCredentials(service: String, login: String?) -> Data {
        var loginData : Data? = nil
        if (login != nil) {
            loginData = Data(Array(login!.trimmingCharacters(in: .whitespacesAndNewlines).utf8))
        }
        return getCredentials(service: Data(Array(service.trimmingCharacters(in: .whitespacesAndNewlines).utf8)), login: loginData)
    }
}