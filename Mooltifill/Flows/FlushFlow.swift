//
// Created by Kai Dederichs on 25.02.22.
//

import Foundation
class FlushFlow: FlowController {
    var data: Data? = nil
    var flushCompleteHandler: () -> Void = { }

    public func startFlush(completion: @escaping () -> ()) {
        flushCompleteHandler = completion;
        self.bluetoothService?.startRead();
    }

    override func received(response: Data) {
        if (data == nil) {
            data = response;
            bluetoothService?.startRead()
        } else {
            if (!data!.elementsEqual(response)) {
                data = response
                bluetoothService?.startRead()
            } else {
                debugPrint("Flush complete")
                flushCompleteHandler()
            }
        }
    }
}