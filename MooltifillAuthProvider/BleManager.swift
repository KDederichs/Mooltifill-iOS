import Foundation

internal class BleManager: NSObject{
    public static var shared = BleManager()
    public var bleManager: MooltipassBleManager
    
    override init() {
        bleManager = MooltipassBleManager()
        super.init()
    }
}
