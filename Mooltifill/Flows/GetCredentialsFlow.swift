//
// Created by Kai Dederichs on 25.02.22.
//

import Foundation

class GetCredentialsFlow: FlowController {
    override func readComplete(data: [Data]) {
        let factory = BleMessageFactory()
        let message = factory.deserialize(data: data)
        if (message?.cmd != MooltipassCommand.GET_CREDENTIAL_BLE) {
            debugPrint("Response is not a Credentials response")
            return
        }

        for p in message!.data! {
            debugPrint(p)
        }

        debugPrint(message?.dataAsString() ?? "Deserialisation failed")
    }
}