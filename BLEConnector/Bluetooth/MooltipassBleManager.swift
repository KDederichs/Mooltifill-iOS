//
//  MooltipassBleManager.swift
//  MooltipassBle
//
//  Created by Kai Dederichs on 12.04.22.
//
//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

public class MooltipassBleManager: NSObject { // 1.
    let FLIP_BIT_RESET_PACKET = Data([0xFF, 0xFF])
    let commServiceUUID     = CBUUID(string: "2566af2c-91bd-49fd-8ebb-020fa873044f")
    let charReadUUID   = CBUUID(string: "4c64e90a-5f9c-4d6b-9c29-bdaa6141f9f7")
    let charWriteUUID = CBUUID(string: "fe8f1a02-6311-475f-a296-553e3566b895")
    let cccDescriptorUUID  = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    public weak var delegate: MooltipassBleDelegate?


    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    var bluetoothState: CBManagerState {
        return self.centralManager.state
    }

    var currentId: Int = 0
    var retryCount: Int = 0
    var readResult: [Data]? = nil

    var flushData: Data? = nil
    var flushing = false

    var deviceLocked : Bool? = nil
    
    var readConnected = false
    var writeConnected = false
    
    var bluetoothAvailable = false
    var connectedCallback: (() -> Void)?
    var commandQueue: Queue<() -> ()> = Queue()
    var noteNames: Set<String> = []
    var noteContent: String = ""
    let factory = BleMessageFactory()
    
    public override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func checkForConnected() -> CBPeripheral? {
        self.delegate?.debugMessage(message: "[MooltipassBleManager] Checking for connected device:")
        let alreadyConnected = centralManager.retrieveConnectedPeripherals(withServices: [commServiceUUID])
        if (alreadyConnected.count > 0) {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Device found")
            self.peripheral = alreadyConnected[0]
            self.delegate?.mooltipassConnected(connected: true)
            return self.peripheral
        }
        self.delegate?.debugMessage(message: "[MooltipassBleManager] Device not found")
        self.delegate?.mooltipassConnected(connected: false)
        return nil
    }

    func startScan() {
        self.peripheral = nil
        guard self.centralManager.state == .poweredOn else { return }


        self.centralManager.scanForPeripherals(withServices: [commServiceUUID]) // 4.
    }

    func stopScan() {
        self.centralManager.stopScan()
    }

    func connect() {
        guard self.centralManager.state == .poweredOn else { return }
        guard let peripheral = self.peripheral else { return }
        self.centralManager.connect(peripheral)
    }

    func disconnect() {
        guard let peripheral = self.peripheral else { return }
        self.centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func connectToMooltipass(callback: (() -> Void)?) {
        connectedCallback = callback
        if (writeConnected && readConnected) {
            if (connectedCallback != nil) {
                self.delegate?.isLoading(loading: true)
                connectedCallback!()
                connectedCallback = nil
                self.delegate?.debugMessage(message: "[MooltipassBleManager] CALLING START FLUSH FROM connectToMooltipass")
                startFlush()
            }
            return
        }
        let possibleConnection = checkForConnected();
        if (possibleConnection != nil) {
            self.delegate?.debugMessage(message: "[MooltipassBleManager] Got Peripheral, connecting")
            self.connect()
        }
    }
}
