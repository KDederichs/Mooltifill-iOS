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
            debugPrint("Flush: Read for nil Data")
            bluetoothService?.startRead()
        } else {
            if (!data!.elementsEqual(response)) {
                data = response
                debugPrint("Flush: Read for missmatch")
                bluetoothService?.startRead()
            } else {
                debugPrint("Flush complete")
                flushCompleteHandler()
            }
        }
    }
}