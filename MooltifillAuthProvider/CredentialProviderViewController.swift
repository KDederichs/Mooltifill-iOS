//
//  CredentialProviderViewController.swift
//  MooltifillAuthProvider
//
//  Created by Kai Dederichs on 12.04.22.
//

import AuthenticationServices
import DomainParser

class CredentialProviderViewController: ASCredentialProviderViewController, MooltipassBleDelegate {
    func noteContentReceived(content: String) {
        
    }
    
    func noteListReceived(notes: [String]) {

    }
    func debugMessage(message: String) {
        updateDebugLabel(message: message)
    }
    
    func credentialNotFound() {
        if (triedRootDomain) {
            _statusLabel.text = "Password not found."
        }
        
        if (service != nil) {
            debugPrint("[CredentialsProvider] Current Service: ", service!)
            let host = getHostPart(service: self.service!)
            if (host != nil) {
                let domain = self.domainParser?.parse(host: host!)?.domain
                if (domain != nil) {
                    debugPrint("[CredentialsProvider] Trying root domain: ", domain!)
                    manager.bleManager.getCredentials(service: domain!, login: nil)
                }
            }
            service = nil
            triedRootDomain = true
        }
    }
    
    func mooltipassConnected(connected: Bool) {
        if (connected) {
            _statusLabel.text = "Device is connected, checking device status."
        } else {
            _statusLabel.text = "Device is not connected, please pair device."
        }
    }
    
    func mooltipassReady() {

    }
    
    
    let manager: BleManager = BleManager.shared
    var triedRootDomain = false
    var alreadyConnected = false
    var service: String? = nil
    var domainParser: DomainParser? = nil
    
    @IBOutlet weak var _statusLabel: UILabel!
    
    func bluetoothChange(enabled: Bool) {
        debugPrint("[CredentialsProvider] Bluetooth enabled:", enabled)
        if (enabled) {
            _statusLabel.text = "Bluetooth is enabled, checking device connection."
            manager.bleManager.getStatus()
        } else {
            _statusLabel.text = "Bluetooth is disabled, please enable Bluetooth."
        }
    }
    
    func onError(errorMessage: String) {
        debugPrint(errorMessage)
        _statusLabel.text = "Error: " + errorMessage
    }
    
    func lockedStatus(locked: Bool) {
        if (locked) {
            _statusLabel.text = "Device is locked, please unlock."
        } else {
            _statusLabel.text = "Device is unlocked, looking up password."
            if (self.service != nil) {
                usleep(useconds_t(200))
                let host = getHostPart(service: self.service!)
                //_statusLabel.text =  host!
                manager.bleManager.getCredentials(service: host != nil ? host! : self.service!, login: nil)
            } else {
                _statusLabel.text = "Error: No service set."
            }
        }
    }
    
    func credentialsReceived(credential: MooltipassCredential?) {
        if (credential == nil) {
            return
        }
        _statusLabel.text = "Password found."
        let passwordCredential = ASPasswordCredential(user: credential!.username, password: credential!.password)
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.bleManager.delegate = self
        do {
            self.domainParser = try DomainParser()
        } catch {
            debugPrint("[CredentialsProvider] Error initialising domain parser: \(error)")
        }
    }

    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        debugPrint("Receiving password")
        self.service = serviceIdentifiers[0].identifier;
        triedRootDomain = false
        // just set URL, password will be fetched through callback chain.
        manager.bleManager.getStatus()
    }

    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.

    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        let databaseIsUnlocked = true
        if (databaseIsUnlocked) {
            let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
        }
    }
    */

    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
    }
    */

    @IBAction func cancel(_ sender: AnyObject?) {
        debugPrint("Canceling")
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }

    @IBAction func passwordSelected(_ sender: AnyObject?) {
        manager.bleManager.getCredentials(service: "github.com", login: nil)
    }
    
    func updateDebugLabel(message: String) {
        //debugPrint(message)
    }

    func getHostPart(service: String) -> String?
    {
        var toCheck = service
        if (!toCheck.starts(with: "http://") && !toCheck.starts(with: "https://")) {
            toCheck = "https://" + service
        }
        
        let url = URL(string: toCheck)
        return url?.host
    }
    
}
