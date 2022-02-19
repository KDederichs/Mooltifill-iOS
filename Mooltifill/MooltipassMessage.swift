//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
import CoreBluetooth
class MooltipassMessage: NSObject {
    public var cmd: MooltipassCommand
    public var data: Data?

    init(cmd: MooltipassCommand) {
        self.cmd = cmd
        data = nil
    }
    init(cmd: MooltipassCommand, s: String) {
        self.cmd = cmd
        data = Data(Array(s.utf8))
    }
    init(cmd: MooltipassCommand, ints: UInt8...) {
        self.cmd = cmd
        data = Data(ints)
    }
    init(cmd: MooltipassCommand, rawData: Data) {
        self.cmd = cmd
        data = rawData
    }

    public func dataAsString(start: Int = 0) -> String {
        if (nil == data) {
            return ""
        }
        for d in data! {
            print(String(d))
        }
        return String(bytes: data!.dropLast(1).dropFirst(start), encoding: .utf8) ?? ""
    }
}