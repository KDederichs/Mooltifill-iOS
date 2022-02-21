//
//  ViewController.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.02.22.
//

import UIKit

class ViewController: UIViewController {

    //Test
    private var mpDevice : MooltipassDevice
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var searchInput: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        mpDevice = MooltipassDevice(bluejay: appDelegate.bluejay)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func onButtonPress(_ sender: Any) {
        print("Button Pressed")
        let random = Data(repeating: UInt8.random(in: 0...255), count: 4)
        let ping = MooltipassMessage(cmd: MooltipassCommand.PING_BLE, rawData: random)
        let msg = MooltipassMessage(cmd: MooltipassCommand.GET_CREDENTIAL_BLE, rawData: MooltipassPayload.getCredentials(service: "amazon.de", login: nil))
        let status = MooltipassMessage(cmd: MooltipassCommand.MOOLTIPASS_STATUS_BLE)

        print("Encoded command")
        mpDevice.communicate(msg: msg)
    }
}

