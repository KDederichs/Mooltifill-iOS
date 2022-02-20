//
//  MooltipassPeripheral.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import CoreBluetooth;
import Bluejay

class MooltipassPeripheral: NSObject {
    public static let commServiceUUID     = ServiceIdentifier(uuid: "2566af2c-91bd-49fd-8ebb-020fa873044f")
    public static let charReadUUID   = CharacteristicIdentifier(uuid: "4c64e90a-5f9c-4d6b-9c29-bdaa6141f9f7", service: commServiceUUID)
    public static let charWriteUUID = CharacteristicIdentifier(uuid: "fe8f1a02-6311-475f-a296-553e3566b895", service: commServiceUUID)
    public static let cccDescriptorUUID  = CharacteristicIdentifier(uuid: "00002902-0000-1000-8000-00805f9b34fb", service: commServiceUUID)

}
