//
// Created by Kai Dederichs on 19.02.22.
//

import CoreBluetooth

class MooltipassDevice: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?

    //Characteristics
    private var readChar: CBCharacteristic?
    private var writeChar: CBCharacteristic?
    private var ccDescriptorChar: CBCharacteristic?

    private var connected = false
    private var factory: BleMessageFactory

    override init() {
        factory = BleMessageFactory()
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Bluetooth state update")
        if central.state != .poweredOn {
            print("Bluetooth is not powered on")
            self.peripheral = nil
        } else {
            let connectedMooltipassPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MooltipassPeripheral.commServiceUUID])
            if (!connectedMooltipassPeripherals.isEmpty) {
                print("Mooltipass is paired and ready!")
                self.peripheral = connectedMooltipassPeripherals[0]
                self.peripheral!.delegate = self
                self.centralManager.connect(self.peripheral!, options: nil)
            } else {
                print("Mooltipass not found (nor paired or out of range)")
            }
        }
    }

    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to to mini BLE")
            connected = true
            peripheral.discoverServices([MooltipassPeripheral.commServiceUUID])
        }
    }

    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == MooltipassPeripheral.commServiceUUID {
                    print("Comm service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([MooltipassPeripheral.charReadUUID,
                                                        MooltipassPeripheral.charWriteUUID,
                                                        MooltipassPeripheral.cccDescriptorUUID], for: service)
                    return
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == MooltipassPeripheral.charReadUUID {
                    print("Char read characteristic found")
                    readChar = characteristic
                } else if characteristic.uuid == MooltipassPeripheral.charWriteUUID {
                    print("Char write characteristic found")
                    writeChar = characteristic
                } else if characteristic.uuid == MooltipassPeripheral.cccDescriptorUUID {
                    print("CCC Descriptor characteristic found");
                    ccDescriptorChar = characteristic
                }
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if (peripheral == self.peripheral) {
            connected = false
            self.peripheral = nil
            readChar = nil
            writeChar = nil
            ccDescriptorChar = nil

            print("Mooltipass disconnected!")
        }
    }

    func peripheral(
            _ peripheral: CBPeripheral,
            didUpdateValueFor characteristic: CBCharacteristic,
            error: Error?
    ) {
        guard let data = characteristic.value else {
            // no data transmitted, handle if needed
            return
        }
        if characteristic.uuid == MooltipassPeripheral.charReadUUID {
            var numberOfPackets = (data[1] % 16) + 1
            var id = data[1] >> 4

            if (0 != id) {

            }
            print(factory.deserialize(data: [data])?.dataAsString() ?? "nope")

            print(data)
            print(id)
            print(numberOfPackets)
        }
    }

    public func send(packets: [Data]) -> Int? {
        var returnValue: Int? = nil
        for paket in packets {
            returnValue = send(packet: paket)
            if (0 != returnValue) {
                return returnValue
            }
        }
        return returnValue
    }

    public func send(packet: Data)-> Int?
    {
        if (!connected) {
            print("Mooltifill: Tried to call send() when Mooltipass is disconnected")
            return nil
        }

        peripheral?.writeValue(packet, for: writeChar!, type: .withoutResponse)
        return 0
    }

    public func communicate(packet: [Data])
    {
        send(packets: packet)
        peripheral?.readValue(for: readChar!)
    }

    public func communicate(msg: MooltipassMessage)
    {
        communicate(packet: factory.serialize(msg: msg))
    }
}
