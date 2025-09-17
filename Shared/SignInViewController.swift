/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The view where the user can sign in, or create an account.
*/

import AuthenticationServices
import UIKit
import os

class SignInViewController: UIViewController {
    
    // IBOutlets
    
    @IBOutlet weak var signInButton: UIButton!

    private var signInObserver: NSObjectProtocol?
    private var signInErrorObserver: NSObjectProtocol?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        signInObserver = NotificationCenter.default.addObserver(forName: .UserSignedIn, object: nil, queue: nil) {_ in
            self.didFinishSignIn()
        }

        signInErrorObserver = NotificationCenter.default.addObserver(forName: .ModalSignInSheetCanceled, object: nil, queue: nil) { _ in
            
        }
        
        // New call to check for passkey
        if let window = self.view.window {
            (UIApplication.shared.delegate as? AppDelegate)?
                .accountManager
                .checkForLocalPasskey(anchor: window) { hasPasskey in
                    if !hasPasskey {
                        self.signInButton.isHidden = true
                    } else{
                        self.signInButton.isHidden = false
                    }
                }
        }
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let signInObserver = signInObserver {
            NotificationCenter.default.removeObserver(signInObserver)
        }

        if let signInErrorObserver = signInErrorObserver {
            NotificationCenter.default.removeObserver(signInErrorObserver)
        }
        
        super.viewDidDisappear(animated)
    }
    
    

    @IBAction func createAccount(_ sender: Any) {

        // Reset Cookie
        Constants.User.sessionId = ""
        
        // Get name of Device
        let deviceName = UIDevice.current.name
        let stripDeviceName = String(deviceName.prefix(4))
        
        let firstName  = "firstName_" + randomString(length: 7)
        let lastName   = "lastName_" + randomString(length: 7)
        let password   = randomString(length: 7)
        
        // Get UUID to match one used in GDPR
        let uuid = UIDevice.current.identifierForVendor?.uuidString
        
        // UserID - name of device+@+random 7 letters + .com
        let p0 = "Kyra" + stripDeviceName + "-" + uuid!
        let p1 = String(p0.prefix(35))
        let p2 = randomString(length: 7)
        var email = "\(p1)@\(p2).com" //UserID
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create account
        RPSAService.shared.createAccount(first: firstName, last: lastName, username: email, password: password) { (response ) in
            
            if let error = response.error {
                self.show(title: "Create Account Error", message: error.localizedDescription) { action in
                    //self.goBack()
                }
            } else {
                // SUCCESS
                
                SettingsManager.shared.setAccount(withName: email)

                // Start creating credentials
                guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
                (UIApplication.shared.delegate as? AppDelegate)?.accountManager.signUpWith(userName: email, anchor: window)
            }
        }
    }
    
    // Random String for account creation
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func show(title: String, message: String, handler: @escaping (_ isOkAction: Bool) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionOk =  UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            return handler(true)
        }
        alertController.addAction(actionOk)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            return handler(false)
        }
        alertController.addAction(actionCancel)
        
        if let controller = self.navigationController?.visibleViewController {
            controller.present(alertController, animated: true)
        } else {
            present(alertController, animated: true)
        }
    }

    @IBAction func showSignInForm(_ sender: Any) {

        // Request auth
        RPSAService.shared.requestAuthentication() { (response ) in
            
            if let error = response.error {
                self.show(title: "Authentication request failed", message: error.localizedDescription) { action in
                    
                }
            } else {
                guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
                (UIApplication.shared.delegate as? AppDelegate)?.accountManager.signInWith(anchor: window, preferImmediatelyAvailableCredentials: true)
            }
        }
    }

    func didFinishSignIn() {
        self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "UserHomeViewController")
    }

    @IBAction func tappedBackground(_ sender: Any) {
        self.view.endEditing(true)
    }
    
}

