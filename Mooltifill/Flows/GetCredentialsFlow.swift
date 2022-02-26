//
// Created by Kai Dederichs on 25.02.22.
//

import Foundation

class GetCredentialsFlow: FlowController {
    override func readComplete(data: [Data]) {
        let factory = BleMessageFactory()
        let message = factory.deserialize(data: data)

        if (message?.cmd == MooltipassCommand.PLEASE_RETRY_BLE) {
            debugPrint("Please retry")
            return
        }

        if (message?.cmd != MooltipassCommand.GET_CREDENTIAL_BLE) {
            debugPrint("Response is not a Credentials response")
            return
        }

        if (message?.data != nil && message!.data!.count > 0) {
            debugPrint(hexEncodedString(message!.data!))
            debugPrint("Login \(parseCredentialsPart(idx: 0, data: message!.data!))")
            debugPrint("Description \(parseCredentialsPart(idx: 2, data: message!.data!))")
            debugPrint("Third \(parseCredentialsPart(idx: 4, data: message!.data!))")
            debugPrint("Password \(parseCredentialsPart(idx: 6, data: message!.data!))")
        }

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

    private func hexEncodedString(_ data: Data?) -> String {
        let format = "0x%02hhX "
        return data?.map { String(format: format, $0) }.joined() ?? ""
    }
}
