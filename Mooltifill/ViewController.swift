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
    
    @IBOutlet weak var searchInput: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        mpDevice = MooltipassDevice()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func onButtonPress(_ sender: Any) {
        print("Button Pressed")
        let msg = MooltipassMessage(cmd: MooltipassCommand.GET_CREDENTIAL_BLE, rawData: MooltipassPayload.getCredentials(service: "amazon.de", login: nil))
        print("Encoded command")
        mpDevice.communicate(msg: msg)
    }
}

