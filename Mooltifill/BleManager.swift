import Foundation
import MooltipassBle
import Combine
import CoreBluetooth

internal class BleManager: NSObject, MooltipassBleDelegate{
    func bluetoothChange(state: CBManagerState) {
        bluetoothEnabledSubject.send((state.rawValue != 0))
    }
    
    func onError(errorMessage: String) {
        mooltiPassErrorSubject.send(errorMessage)
    }
    
    func lockedStatus(locked: Bool) {
        lockedSubject.send(locked)
    }
    
    func credentialsReceived(credential: MooltipassBle.MooltipassCredential?) {
        guard let cred = credential else {
              return
          }
        
        mooltipassCredentialSubject.send(cred)
    }
    
    func mooltipassConnected() {
        mooltipassConnectedSubject.send(true)
    }
    
    public static var shared = BleManager()
    public var bleManager: MooltipassBleManager
    
    var locked: AnyPublisher<Bool, Never> {
        lockedSubject.eraseToAnyPublisher()
    }
    
    var bluetoothEnabled: AnyPublisher<Bool, Never> {
        bluetoothEnabledSubject.eraseToAnyPublisher()
    }
    
    var isMooltipassConnected: AnyPublisher<Bool, Never> {
        mooltipassConnectedSubject.eraseToAnyPublisher()
    }
    
    var mooltipassError: AnyPublisher<String, Never> {
        mooltiPassErrorSubject.eraseToAnyPublisher()
    }
    
    var credential: AnyPublisher<MooltipassCredential, Never> {
        mooltipassCredentialSubject.eraseToAnyPublisher()
    }
    
    private let lockedSubject = PassthroughSubject<Bool, Never>()
    private let bluetoothEnabledSubject = PassthroughSubject<Bool, Never>()
    private let mooltipassConnectedSubject = PassthroughSubject<Bool, Never>()
    private let mooltiPassErrorSubject = PassthroughSubject<String, Never>()
    private let mooltipassCredentialSubject = PassthroughSubject<MooltipassCredential, Never>()
    
    override init() {
        bleManager = MooltipassBleManager()
        super.init()
    }
    
    deinit {
        lockedSubject.send(completion: .finished)
        bluetoothEnabledSubject.send(completion: .finished)
        mooltipassConnectedSubject.send(completion: .finished)
        mooltiPassErrorSubject.send(completion: .finished)
        mooltipassCredentialSubject.send(completion: .finished)
    }
}
