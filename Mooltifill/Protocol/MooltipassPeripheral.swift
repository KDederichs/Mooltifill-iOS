//
//  MooltipassPeripheral.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import CoreBluetooth;

class MooltipassPeripheral: NSObject {
    public static let commServiceUUID     = CBUUID.init(string: "2566af2c-91bd-49fd-8ebb-020fa873044f")
    public static let charReadUUID   = CBUUID.init(string: "4c64e90a-5f9c-4d6b-9c29-bdaa6141f9f7")
    public static let charWriteUUID = CBUUID.init(string: "fe8f1a02-6311-475f-a296-553e3566b895")
    public static let cccDescriptorUUID  = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")

}
