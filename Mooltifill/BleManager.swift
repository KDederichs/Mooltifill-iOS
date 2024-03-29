import Foundation
import Combine
import DomainParser

internal class BleManager: NSObject, MooltipassBleDelegate {
    
    func debugMessage(message: String) {
        debugPrint(message)
    }
    
    var service : String? = nil
    
    func credentialNotFound() {
        debugPrint("[BleManager] Credential was not found.")
        if (service != nil) {
            debugPrint("[BleManager] Current Service: ", service!)
            do {
                let domainParse = try DomainParser()
                debugPrint("[BleManager] Domain Parser Initialisation success.")
                let domain = domainParse.parse(host: service!)?.domain
                
                if (domain != nil) {
                    debugPrint("[BleManager] Trying root domain: ", domain!)
                    bleManager.getCredentials(service: domain!, login: nil)
                }
            } catch {
                debugPrint("[BleManager] Error initialising domain parser: \(error)")
            }
            service = nil
        }
    }
    
    func mooltipassConnected(connected: Bool) {
        debugPrint("[BleManager] Device is connected:", connected)
        mooltipassConnectedSubject.send(connected)
    }
    
    func mooltipassReady() {
        debugPrint("[BleManager] Device is ready")
        mooltipassReadySubject.send(true)
    }
    
    func bluetoothChange(enabled: Bool) {
        debugPrint("[BleManager] Bluetooth enabled:", enabled)
        bluetoothEnabledSubject.send(enabled)
        
        if (enabled) {
            bleManager.getStatus()
        }
    }
    
    func isLoading(loading: Bool) {
        mooltipassLoadingSubject.send(loading)
    }
    
    func onError(errorMessage: String) {
        mooltiPassErrorSubject.send(errorMessage)
    }
    
    func lockedStatus(locked: Bool) {
        debugPrint("[BleManager] Locked Status changed to", locked)
        lockedSubject.send(locked)
    }
    
    func credentialsReceived(credential: MooltipassCredential?) {
        debugPrint("[BleManager] Received Credential")
        guard let cred = credential else {
            debugPrint("[BleManager] It's empty :(")
              return
          }
        debugPrint("[BleManager] Publishing Credential")
        mooltipassCredentialSubject.send(cred)
    }
    
    func noteListReceived(notes: [String]) {
        debugPrint("[BleManager] Received NoteList")
        mooltipassNotesSubject.send(notes)
    }
    
    func noteContentReceived(content: String) {
        debugPrint("[BleManager] Received Note Content: " + content)
        mooltipassNotesContentSubject.send(content)
    }
    
    func fetchCredential(service: String, login: String?) {
        self.service = service
        bleManager.getCredentials(service: service, login: login)
    }
    
    func getNoteList() {
        bleManager.getNoteList()
    }
    
    func getNoteData(noteName: String) {
        bleManager.getNoteContent(noteName: noteName )
    }

    
    struct Static
    {
        public static var instance: BleManager?
    }
    
    class var shared: BleManager
     {
         if Static.instance == nil
         {
             Static.instance = BleManager()
         }

         return Static.instance!
     }
    
    public var bleManager: MooltipassBleManager
    
    public func dispose()
    {
        Static.instance?.bleManager.disconnect()
        Static.instance = nil
        print("[BleManager] Disposed Singleton instance")
    }
    
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
    
    public var notes: AnyPublisher<[String], Never> {
        mooltipassNotesSubject.eraseToAnyPublisher()
    }
    public var noteContent: AnyPublisher<String, Never> {
        mooltipassNotesContentSubject.eraseToAnyPublisher()
    }
    
    public var ready: AnyPublisher<Bool, Never> {
        mooltipassReadySubject.eraseToAnyPublisher()
    }
    
    public var isLoading: AnyPublisher<Bool, Never> {
        mooltipassLoadingSubject.eraseToAnyPublisher()
    }
    
    private let lockedSubject = PassthroughSubject<Bool, Never>()
    private let bluetoothEnabledSubject = PassthroughSubject<Bool, Never>()
    private let mooltipassConnectedSubject = PassthroughSubject<Bool, Never>()
    private let mooltipassReadySubject = PassthroughSubject<Bool, Never>()
    private let mooltiPassErrorSubject = PassthroughSubject<String, Never>()
    private let mooltipassCredentialSubject = PassthroughSubject<MooltipassCredential, Never>()
    private let mooltipassNotesSubject = PassthroughSubject<[String], Never>()
    private let mooltipassNotesContentSubject = PassthroughSubject<String, Never>()
    private let mooltipassLoadingSubject = PassthroughSubject<Bool, Never>()
    
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
        mooltipassReadySubject.send(completion: .finished)
        mooltipassNotesSubject.send(completion: .finished)
        mooltipassNotesContentSubject.send(completion: .finished)
        mooltipassLoadingSubject.send(completion: .finished)
        bleManager.delegate = nil
    }
}
