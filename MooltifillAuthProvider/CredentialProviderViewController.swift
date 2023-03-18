//
//  CredentialProviderViewController.swift
//  MooltifillAuthProvider
//
//  Created by Kai Dederichs on 12.04.22.
//

import AuthenticationServices
import DomainParser

class CredentialProviderViewController: ASCredentialProviderViewController, MooltipassBleDelegate {
    func credentialNotFound() {
        if (triedRootDomain) {
            _statusLabel.text = "Password not found."
        }
        
        if (url != nil) {
            debugPrint("[CredentialsProvider] Current Service: ", url!.host!)
            do {
                let domainParse = try DomainParser()
                debugPrint("[CredentialsProvider] Domain Parser Initialisation success.")
                let domain = domainParse.parse(host: url!.host!)?.domain
                
                if (domain != nil) {
                    debugPrint("[CredentialsProvider] Trying root domain: ", domain!)
                    manager.bleManager.getCredentials(service: domain!, login: nil)
                }
            } catch {
                debugPrint("[CredentialsProvider] Error initialising domain parser: \(error)")
            }
            url = nil
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
    var url: URL? = nil
    var triedRootDomain = false
    var alreadyConnected = false
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
        print(errorMessage)
        _statusLabel.text = "Error: " + errorMessage
    }
    
    func lockedStatus(locked: Bool) {
        if (locked) {
            _statusLabel.text = "Device is locked, please unlock."
            debugPrint("Device Locked")
        } else {
            debugPrint("Device Unlocked")
            _statusLabel.text = "Device is unlocked, looking up password."
            if (url != nil) {
                usleep(useconds_t(200))
                manager.bleManager.getCredentials(service: url!.host!, login: nil)
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
    }

    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        debugPrint("Receiving password")
        let service = serviceIdentifiers[0].identifier;
        triedRootDomain = false
        // just set URL, password will be fetched through callback chain.
        url = URL(string: service)
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

}
