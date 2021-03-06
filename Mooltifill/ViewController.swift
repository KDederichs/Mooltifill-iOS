//
//  ViewController.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import UIKit
import MooltipassBle
import CoreBluetooth

class ViewController: UIViewController, MooltipassBleDelegate {
    func bluetoothChange(state: CBManagerState) {
        
    }
    
    func onError(errorMessage: String) {
        print("Mooltipass Error: \(errorMessage)")
    }
    
    func lockedStatus(locked: Bool) {
        print("Locked \(locked)")
    }
    
    func credentialsReceived(username: String, password: String) {
        print(username)
        print(password)
    }
    
    func mooltipassConnected() {
        
    }
    

    //Test
    //private var mpDevice : MooltipassDevice
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let bleManager = BleManager.shared

    
    
    @IBOutlet weak var searchInput: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bleManager.bleManager.delegate = self
    }


    @IBAction func onButtonPress(_ sender: Any) {
        bleManager.bleManager.getCredentials(service: "test.de", login: nil)

        print("Encoded command")
        //mpDevice.communicate(msg: msg)x
        //mpDevice.send(packet: MooltipassPayload.FLIP_BIT_RESET_PACKET, readAfter: false)
        //mpDevice.send(packet: Data([0x28, 0x00, 0x07, 0x00, 0x24, 0x00, 0x00, 0x00, 0xff, 0xff, 0x63, 0x00, 0x72, 0x00, 0x75, 0x00, 0x6e, 0x00, 0x63, 0x00, 0x68, 0x00, 0x79, 0x00, 0x72, 0x00, 0x6f, 0x00, 0x6c, 0x00, 0x6c, 0x00, 0x2e, 0x00, 0x63, 0x00, 0x6f, 0x00, 0x6d, 0x00, 0x00, 0x00]))
    }
}

