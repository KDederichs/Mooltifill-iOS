//
//  BleManager.swift
//  MooltifillAuthProvider
//
//  Created by Kai Dederichs on 11.04.22.
//

import Foundation
import MooltipassBLE

internal class BleManager: NSObject{
    public static var shared = BleManager()
    public var service: BluetoothService
    
    override init() {
        service = BluetoothService()
        super.init()
    }
}
