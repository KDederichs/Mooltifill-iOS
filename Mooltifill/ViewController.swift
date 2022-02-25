//
//  ViewController.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import UIKit

class ViewController: UIViewController {

    //Test
    //private var mpDevice : MooltipassDevice
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    
    @IBOutlet weak var searchInput: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.bluetoothService.flowController = appDelegate.pairingFlow

    }


    @IBAction func onButtonPress(_ sender: Any) {
        print("Button Pressed")
        let random = Data(repeating: UInt8.random(in: 0...255), count: 4)
        let ping = MooltipassMessage(cmd: MooltipassCommand.PING_BLE, rawData: random)
        let msg = MooltipassMessage(cmd: MooltipassCommand.GET_CREDENTIAL_BLE, rawData: MooltipassPayload.getCredentials(service: "amazon.de", login: nil))
        let status = MooltipassMessage(cmd: MooltipassCommand.MOOLTIPASS_STATUS_BLE)

        print("Encoded command")
        //mpDevice.communicate(msg: msg)x
        //mpDevice.send(packet: MooltipassPayload.FLIP_BIT_RESET_PACKET, readAfter: false)
        //mpDevice.send(packet: Data([0x28, 0x00, 0x07, 0x00, 0x24, 0x00, 0x00, 0x00, 0xff, 0xff, 0x63, 0x00, 0x72, 0x00, 0x75, 0x00, 0x6e, 0x00, 0x63, 0x00, 0x68, 0x00, 0x79, 0x00, 0x72, 0x00, 0x6f, 0x00, 0x6c, 0x00, 0x6c, 0x00, 0x2e, 0x00, 0x63, 0x00, 0x6f, 0x00, 0x6d, 0x00, 0x00, 0x00]))
    }
}

