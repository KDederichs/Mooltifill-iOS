//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
import Bluejay

class MooltipassDevice: ConnectionObserver {
    // Properties
//    private var centralManager: CBCentralManager!
//    private var peripheral: CBPeripheral?
//
//    //Characteristics
//    private var readChar: CBCharacteristic?
//    private var writeChar: CBCharacteristic?
//    private var ccDescriptorChar: CBCharacteristic?
//
//    private var connected = false
    private var bluejay: Bluejay
    
    private var mooltipassPeripheral: PeripheralIdentifier?
    
    func bluetoothAvailable(_ available: Bool) {
        print("Bluetooth available")
        if (available) {
            let connectedPeriph = bluejay.cbCentralManager.retrieveConnectedPeripherals(withServices: [MooltipassPeripheral.commServiceUUID.uuid])
            print(connectedPeriph.count)
            let mpBle = connectedPeriph.filter() { peripheral in peripheral.name == "Mooltipass BLE" }.first
            if (mpBle != nil) {
                print("Found Mooltipass \(String(describing: mpBle!.name)) \(mpBle!.identifier)")
                let bluejayPeriph = PeripheralIdentifier(uuid: mpBle!.identifier, name: mpBle!.name)
                bluejay.connect(bluejayPeriph, timeout: .seconds(15)) { result in
                    switch result {
                    case .success:
                        debugPrint("Connection attempt to: \(bluejayPeriph.description) is successful")
                    case .failure(let error):
                        debugPrint("Failed to connect with error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    func connected(to peripheral: PeripheralIdentifier) {
        print("Connected to \(peripheral.name)")
        self.mooltipassPeripheral = peripheral
    }
    func disconnected(from peripheral: PeripheralIdentifier) {
        print("Disconnected from \(peripheral.name)")
    }

    init(bluejay: Bluejay) {
        self.bluejay = bluejay
        self.bluejay.register(connectionObserver: self)
    }

//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        print("Bluetooth state update")
//        if central.state != .poweredOn {
//            print("Bluetooth is not powered on")
//            self.peripheral = nil
//        } else {
//            let connectedMooltipassPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MooltipassPeripheral.commServiceUUID])
//            if (!connectedMooltipassPeripherals.isEmpty) {
//                print("Mooltipass is paired and ready!")
//                self.peripheral = connectedMooltipassPeripherals[0]
//                self.peripheral!.delegate = self
//                self.centralManager.connect(self.peripheral!, options: nil)
//            } else {
//                print("Mooltipass not found (nor paired or out of range)")
//            }
//        }
//    }
//
//    // The handler if we do connect succesfully
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        if peripheral == self.peripheral {
//            print("Connected to to mini BLE")
//            connected = true
//            peripheral.discoverServices([MooltipassPeripheral.commServiceUUID])
//        }
//    }
//
//    // Handles discovery event
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services {
//            for service in services {
//                if service.uuid == MooltipassPeripheral.commServiceUUID {
//                    print("Comm service found")
//                    //Now kick off discovery of characteristics
//                    peripheral.discoverCharacteristics([MooltipassPeripheral.charReadUUID,
//                                                        MooltipassPeripheral.charWriteUUID,
//                                                        MooltipassPeripheral.cccDescriptorUUID], for: service)
//                    return
//                }
//            }
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let characteristics = service.characteristics {
//            for characteristic in characteristics {
//                if characteristic.uuid == MooltipassPeripheral.charReadUUID {
//                    print("Char read characteristic found")
//                    readChar = characteristic
//                } else if characteristic.uuid == MooltipassPeripheral.charWriteUUID {
//                    print("Char write characteristic found")
//                    writeChar = characteristic
//                } else if characteristic.uuid == MooltipassPeripheral.cccDescriptorUUID {
//                    print("CCC Descriptor characteristic found");
//                    ccDescriptorChar = characteristic
//                }
//            }
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        if (peripheral == self.peripheral) {
//            connected = false
//            self.peripheral = nil
//            readChar = nil
//            writeChar = nil
//            ccDescriptorChar = nil
//
//            print("Mooltipass disconnected!")
//        }
//    }
//
//    func peripheral(
//            _ peripheral: CBPeripheral,
//            didUpdateValueFor characteristic: CBCharacteristic,
//            error: Error?
//    ) {
//        guard let data = characteristic.value else {
//            // no data transmitted, handle if needed
//            return
//        }
//        if characteristic.uuid == MooltipassPeripheral.charReadUUID {
//
//            for p in data {
//                print(String(p))
//            }
//
//            var numberOfPackets = (data[1] % 16) + 1
//            var id = data[1] >> 4
//
//            if (0 != id) {
//
//            }
//            print(factory.deserialize(data: [data])?.dataAsString() ?? "nope")
//
//            print(data)
//            print(id)
//            print(numberOfPackets)
//        }
//    }
//
//    func peripheral(
//            _ peripheral: CBPeripheral,
//            didWriteValueFor characteristic: CBCharacteristic,
//            error: Error?
//    ) {
//        print(characteristic.uuid)
//        if (error != nil) {
//            print(error!.localizedDescription)
//        }
//        self.peripheral!.readValue(for: readChar!)
//    }

    public func send(packets: [Data]) -> Int? {
        print("Send packets")
        var returnValue: Int? = nil
        for paket in packets {
            print("Sending packet")
            returnValue = send(packet: paket)
            if (0 != returnValue) {
                return returnValue
            }
        }
        return returnValue
    }

    public func send(packet: Data, readAfter: Bool = true)-> Int?
    {
        print("sending single packet")
        if (!bluejay.isConnected) {
            print("Mooltifill: Tried to call send() when Mooltipass is disconnected")
            return nil
        }

        debugPrint("%%%%%%Sending%%%%%")
        for p in packet {
            print(String(p))
        }
        debugPrint("%%%%%%End Sending%%%%%")
        bluejay.write(to: MooltipassPeripheral.charWriteUUID, value: packet) { result in
            switch result {
            case .success:
                debugPrint("Write to sensor location is successful.")
                if (readAfter) {
                    self.readVal()
                }
            case .failure(let error):
                debugPrint("Failed to write sensor location with error: \(error.localizedDescription)")
            }
        }
        return 0
    }

    private func readInternal(peripheral: SynchronizedPeripheral) throws -> Data {
        try peripheral.read(from: MooltipassPeripheral.charReadUUID)
    }

    public func readVal() {
        bluejay.run(backgroundTask: { [self] (peripheral) -> [Data]? in
            let packet = try readInternal(peripheral: peripheral)
            let numberOfPackets = (packet[1] % 16) + 1
            let id = packet[1] >> 4
            if (0 != id) {
                print("First packet should have 0, but was \(id)")
                return nil
            }
            debugPrint("%%%%%%Reading%%%%%")
            for p in packet {
                print(p)
            }
            debugPrint("%%%%%%End Reading%%%%%")
            var returnData = [Data](repeating: Data([0]), count: Int(numberOfPackets))
            returnData[0] = packet
            for i in 1..<numberOfPackets {
                debugPrint("Fetching more")
                returnData[Int(i)] = try readInternal(peripheral: peripheral)
            }
            return returnData
        },  completionOnMainThread: { (result) in
            switch result {
            case .success(let readResult):
                if (nil != readResult) {
                    debugPrint("Read success")
                    let factory = BleMessageFactory()
                    let msg = factory.deserialize(data: readResult!)
                    if (nil != msg) {
                        print(msg!.cmd)
                    }
                } else {
                    debugPrint("Read failed")
                }
            case .failure(let error):
                debugPrint("Background task failed with error: \(error.localizedDescription)")
            }
        })
    }

    public func communicate(packet: [Data])
    {
        print("Comminucate packet")
        send(packet: MooltipassPayload.FLIP_BIT_RESET_PACKET, readAfter: false)
        send(packets: packet)
        //peripheral?.readValue(for: readChar!)
    }

    public func communicate(msg: MooltipassMessage)
    {
        let factory = BleMessageFactory()
        print("Comminucate command")
        communicate(packet: factory.serialize(msg: msg))
    }
}
