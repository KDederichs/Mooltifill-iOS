//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
import CoreBluetooth
public class MooltipassMessage {
    public var cmd: MooltipassCommand
    public var data: Data?

    public init(cmd: MooltipassCommand) {
        self.cmd = cmd
        data = nil
    }
    public init(cmd: MooltipassCommand, s: String) {
        self.cmd = cmd
        data = Data(Array(s.utf8))
    }
    public init(cmd: MooltipassCommand, ints: UInt8...) {
        self.cmd = cmd
        data = Data(ints)
    }
    public init(cmd: MooltipassCommand, rawData: Data) {
        self.cmd = cmd
        data = rawData
    }

    public func dataAsString(start: Int = 0) -> String {
        if (nil == data) {
            return ""
        }
        return String(bytes: data!.dropLast(1).dropFirst(start), encoding: String.Encoding.ascii) ?? ""
    }
}
