import Foundation
import MooltipassBle
import Combine
import CoreBluetooth

internal class BleManager: NSObject, MooltipassBleDelegate{
    func bluetoothChange(state: CBManagerState) {
        let bluetoothEnabled = (state.rawValue != 0)
        debugPrint("[BleManager] Bluetooth enabled:", bluetoothEnabled)
        bluetoothEnabledSubject.send(bluetoothEnabled)
        
        if (bluetoothEnabled) {
            bleManager.getStatus()
        }
    }
    
    func onError(errorMessage: String) {
        mooltiPassErrorSubject.send(errorMessage)
    }
    
    func lockedStatus(locked: Bool) {
        debugPrint("[BleManager] Locked Status changed to", locked)
        lockedSubject.send(locked)
    }
    
    func credentialsReceived(credential: MooltipassBle.MooltipassCredential?) {
        debugPrint("[BleManager] Received Credential")
        guard let cred = credential else {
            debugPrint("[BleManager] It's empty :(")
              return
          }
        debugPrint("[BleManager] Publishing Credential")
        mooltipassCredentialSubject.send(cred)
    }
    
    func mooltipassConnected() {
        debugPrint("[BleManager] Device is connected")
        mooltipassConnectedSubject.send(true)
    }
    
    public static var shared = BleManager()
    public var bleManager: MooltipassBleManager
    
    public var locked: AnyPublisher<Bool, Never> {
        lockedSubject.eraseToAnyPublisher()
    }
    
    public var bluetoothEnabled: AnyPublisher<Bool, Never> {
        bluetoothEnabledSubject.eraseToAnyPublisher()
    }
    
    public var isMooltipassConnected: AnyPublisher<Bool, Never> {
        mooltipassConnectedSubject.eraseToAnyPublisher()
    }
    
    public var mooltipassError: AnyPublisher<String, Never> {
        mooltiPassErrorSubject.eraseToAnyPublisher()
    }
    
    public var credential: AnyPublisher<MooltipassCredential, Never> {
        mooltipassCredentialSubject.eraseToAnyPublisher()
    }
    
    private let lockedSubject = PassthroughSubject<Bool, Never>()
    private let bluetoothEnabledSubject = PassthroughSubject<Bool, Never>()
    private let mooltipassConnectedSubject = PassthroughSubject<Bool, Never>()
    private let mooltiPassErrorSubject = PassthroughSubject<String, Never>()
    private let mooltipassCredentialSubject = PassthroughSubject<MooltipassCredential, Never>()
    
    override init() {
    
        debugPrint("[BleManager] Init")
        bleManager = MooltipassBleManager()
        super.init()
        bleManager.delegate = self
    }
    
    deinit {
        debugPrint("[BleManager] Deinit")
        lockedSubject.send(completion: .finished)
        bluetoothEnabledSubject.send(completion: .finished)
        mooltipassConnectedSubject.send(completion: .finished)
        mooltiPassErrorSubject.send(completion: .finished)
        mooltipassCredentialSubject.send(completion: .finished)
    }
}
