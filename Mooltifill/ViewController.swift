//
//  ViewController.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import UIKit
import CoreBluetooth;

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    
    //Scan for Mooltipass
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            let connectedMooltipassPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MooltipassPeripheral.commServiceUUID])
            if (connectedMooltipassPeripherals.isEmpty) {
                print("Mooltipass not paired, scanning for", MooltipassPeripheral.commServiceUUID);
                centralManager.scanForPeripherals(withServices: nil,
                                                  options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            } else {
                print("Mooltipass already connected!")
                self.peripheral = connectedMooltipassPeripherals[0]
                self.peripheral.delegate = self
                self.centralManager.connect(self.peripheral, options: nil)
            }
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name != nil) {
            print("Found " + peripheral.name!)
        } else {
            print("Found " + peripheral.identifier.uuidString)
        }
        // We've found it so stop scan
//        self.centralManager.stopScan()
//
//        // Copy the peripheral instance
//        self.peripheral = peripheral
//        self.peripheral.delegate = self
//
//        // Connect!
//        self.centralManager.connect(self.peripheral, options: nil)

    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to to mini BLE")
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
    
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == MooltipassPeripheral.charReadUUID {
                    print("Char read characteristic found")
                } else if characteristic.uuid == MooltipassPeripheral.charWriteUUID {
                    print("Char write characteristic found")
                } else if characteristic.uuid == MooltipassPeripheral.cccDescriptorUUID {
                    print("CCC Descriptor characteristic found");
                }
            }
        }
    }

}

