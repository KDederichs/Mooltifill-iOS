//
// Created by Kai Dederichs on 23.02.22.
//

import Foundation
import CoreBluetooth

class BluetoothService: NSObject { // 1.

    let commServiceUUID     = CBUUID(string: "2566af2c-91bd-49fd-8ebb-020fa873044f")
    let charReadUUID   = CBUUID(string: "4c64e90a-5f9c-4d6b-9c29-bdaa6141f9f7")
    let charWriteUUID = CBUUID(string: "fe8f1a02-6311-475f-a296-553e3566b895")
    let cccDescriptorUUID  = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")


    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    var bluetoothState: CBManagerState {
        return self.centralManager.state
    }
    var flowController: FlowController? // 3.

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func checkForConnected() -> CBPeripheral? {
        let alreadyConnected = centralManager.retrieveConnectedPeripherals(withServices: [commServiceUUID])
        if (alreadyConnected.count > 0 && alreadyConnected[0].name == "Mooltipass BLE") {
            self.peripheral = alreadyConnected[0]
            return self.peripheral
        }
        return nil
    }

    func startScan() {
        self.peripheral = nil
        guard self.centralManager.state == .poweredOn else { return }


        self.centralManager.scanForPeripherals(withServices: [commServiceUUID]) // 4.
        self.flowController?.scanStarted() // 5.
        print("scan started")
    }

    func stopScan() {
        self.centralManager.stopScan()
        self.flowController?.scanStopped() // 5.
        print("scan stopped\n")
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
}