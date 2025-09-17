/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The authentication manager object.
*/

import AuthenticationServices
import Foundation
import os
import SwiftCBOR

extension NSNotification.Name {
    static let UserSignedIn = Notification.Name("UserSignedInNotification")
    static let ModalSignInSheetCanceled = Notification.Name("ModalSignInSheetCanceledNotification")
}

class AccountManager: NSObject, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    let domain = "emea-rp.identityx-cloud.com"
    var authenticationAnchor: ASPresentationAnchor?
    var isPerformingModalRequest = false
    private var isAuthInProgress = false
    private var currentAuthController: ASAuthorizationController?
    private var passkeyChecker: PasskeyChecker?
    
    func signInWith(anchor: ASPresentationAnchor, preferImmediatelyAvailableCredentials: Bool) {
        self.authenticationAnchor = anchor
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)

        // Fetch the challenge from the server. The challenge needs to be unique for each request.
        // Decode base64 challenge (base64url ➝ base64 ➝ Data)
        let base64Challenge = base64UrlToBase64(Constants.User.CREDENTIAL_REQUEST_CHALLENGE)
        guard let challengeData = Data(base64Encoded: base64Challenge) else {
            print("❌ Failed to decode base64url challenge")
            isAuthInProgress = false
            return
        }

        let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challengeData)

        // Also allow the user to use a saved password, if they have one.
        let passwordCredentialProvider = ASAuthorizationPasswordProvider()
        let passwordRequest = passwordCredentialProvider.createRequest()

        // Pass in any mix of supported sign-in request types.
        let authController = ASAuthorizationController(authorizationRequests: [ assertionRequest, passwordRequest ] )
        authController.delegate = self
        authController.presentationContextProvider = self

        if preferImmediatelyAvailableCredentials {
            // If credentials are available, presents a modal sign-in sheet.
            // If there are no locally saved credentials, no UI appears and
            // the system passes ASAuthorizationError.Code.canceled to call
            // `AccountManager.authorizationController(controller:didCompleteWithError:)`.
            authController.performRequests(options: .preferImmediatelyAvailableCredentials)
        } else {
            // If credentials are available, presents a modal sign-in sheet.
            // If there are no locally saved credentials, the system presents a QR code to allow signing in with a
            // passkey from a nearby device.
            authController.performRequests()
        }

        isPerformingModalRequest = true
    }
    
    func checkForLocalPasskey(anchor: ASPresentationAnchor, completion: @escaping (Bool) -> Void) {
       
        // Initialize PasskeyChecker with the decoded challenge, relying party domain, and presentation anchor
        passkeyChecker = PasskeyChecker(
            challenge: Constants.User.CREDENTIAL_REQUEST_CHALLENGE,
            relyingPartyID: domain,
            presentationAnchor: anchor
        )
        
        // Perform local passkey availability check
        passkeyChecker?.checkLocalPasskeyAvailability { hasPasskey in
            DispatchQueue.main.async {
                if hasPasskey {
                    print("Local passkey found. Attempting silent sign-in.")
                } else {
                    print("No local passkey found.")
                }
                // Report back result
                completion(hasPasskey)
                
                // Release reference if you no longer need it
                self.passkeyChecker = nil
            }
        }
    }


    // AUTHENTICATE PASSKEY
    func beginAutoFillAssistedPasskeySignIn(anchor: ASPresentationAnchor) {

        self.authenticationAnchor = anchor

        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)

        // Decode base64 challenge (base64url ➝ base64 ➝ Data)
        let base64Challenge = base64UrlToBase64(Constants.User.CREDENTIAL_REQUEST_CHALLENGE)
        guard let challengeData = Data(base64Encoded: base64Challenge) else {
            print("Failed to decode base64url challenge")
            isAuthInProgress = false
            return
        }
        
        // Fetch the challenge from the server. The challenge needs to be unique for each request.
        //let challengeData = Data()

        // ✅ Ensure challenge is valid (log for debugging)
        print("Challenge Data (base64): \(challengeData.base64EncodedString())")

        let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challengeData)

        // Optionally allow only platform credentials
        assertionRequest.allowedCredentials = [] // <-- Remove if you want to allow all

        let authController = ASAuthorizationController(authorizationRequests: [assertionRequest])
        authController.delegate = self
        authController.presentationContextProvider = self

        // ✅ Fallback for iOS < 17 or if AutoFill fails
        if #available(iOS 17.0, *) {
            authController.performAutoFillAssistedRequests()
        } else {
            authController.performRequests()
        }

        self.currentAuthController = authController
    }

    
    func generateChallenge() -> Data {
        return Data((0..<32).map { _ in UInt8.random(in: 0...255) })
    }
     
    // REGISTRATION OF PASSKEY
    func signUpWith(userName: String, anchor: ASPresentationAnchor) {
        self.authenticationAnchor = anchor
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)

        // Use raw challenge string as UTF-8 data

        let base64Challenge = base64UrlToBase64(Constants.User.CREDENTIAL_REQUEST_CHALLENGE)
        guard let challengeData = Data(base64Encoded: base64Challenge) else {
            print("Failed to decode base64url challenge")
            return
        }
        
        // Create a user ID
        let userID = Data(Constants.User.accountId.utf8)//Data(UUID().uuidString.utf8)

        // Create the credential registration request
        let registrationRequest = publicKeyCredentialProvider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: userName,
            userID: userID
        )

        // Enable attestation
        registrationRequest.attestationPreference = .none
        
        // NOTE: Apple explicitly disables attestation when using passkeys.

        // Create the authorization controller and start the request
        let authController = ASAuthorizationController(authorizationRequests: [registrationRequest])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
        isPerformingModalRequest = true
        
        //This should call the delegate method below  - didCompleteWithAuthorization...
    }
    
    

    func toBase64url(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        let logger = Logger()
        
        switch authorization.credential {
        
        case let credentialRegistration as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            logger.log("A new passkey was registered: \(credentialRegistration)")
            // Verify the attestationObject and clientDataJSON with your service.
            // The attestationObject contains the user's new public key to store and use for subsequent sign-ins.
            if let attestationObject = credentialRegistration.rawAttestationObject {
                Constants.User.AttestationObject = toBase64url(attestationObject)
            }
            
            Constants.User.clientDataJSON = String(data: credentialRegistration.rawClientDataJSON, encoding: .utf8)!
            Constants.User.credentialID = toBase64url(credentialRegistration.credentialID)
           
            let jsonString = Constants.User.clientDataJSON
            var signedChallenge: String?

            if let jsonData = jsonString.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
               let jsonDict = jsonObject as? [String: Any],
               let extractedChallenge = jsonDict["challenge"] as? String {
                
                signedChallenge = extractedChallenge
            } else {
                print("Failed to parse challenge from clientDataJSON")
            }

            RPSAService.shared.updateCredentials { result, error in
                if let error = error {
                    print("Registration update failed: \(error.localizedDescription)")
                } else if let result = result {
                    print("Registration update succeeded with response: \(result)")
                } else {
                    print("Unknown error during registration update")
                }
            }
            // After the server verifies the registration and creates the user account, sign in the user with the new account.
            didFinishSignIn()
        
        case let credentialAssertion as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            // PASSKEY AUTHENTICATION
            
            logger.log("A passkey was used to sign in: \(credentialAssertion)")
            
            Constants.User.clientDataJSON = String(data: credentialAssertion.rawClientDataJSON, encoding: .utf8)!
            Constants.User.credentialID = toBase64url(credentialAssertion.credentialID)
            Constants.User.signature = toBase64url(credentialAssertion.signature)
            
            if let authenticatorData = credentialAssertion.rawAuthenticatorData {
                Constants.User.authenticatorData = toBase64url(authenticatorData)
            }
            
            // This will be the account name
            let originalString = SettingsManager.shared.account()

            // Convert the string to Data
            if let data = originalString!.data(using: .utf8) {
                // Encode the data to Base64
                Constants.User.userID = toBase64url(data)
            } else {
                print("Failed to convert string to data")
            }
            
            RPSAService.shared.postSessions { result, error in
                if let error = error {
                    print("Registration update failed: \(error.localizedDescription)")
                } else if let result = result {
                    print("Registration update succeeded with response: \(result)")
                } else {
                    print("Unknown error during registration update")
                }
                
                // After the server verifies the assertion, sign in the user.
                self.didFinishSignIn()
            }
            
            
            
        case let passwordCredential as ASPasswordCredential:
            logger.log("A password was provided: \(passwordCredential)")
            // Verify the userName and password with your service.
            // let userName = passwordCredential.user
            // let password = passwordCredential.password

            // After the server verifies the userName and password, sign in the user.
            didFinishSignIn()
        default:
            fatalError("Received unknown authorization type.")
        }

        isPerformingModalRequest = false
    }
    
    func extractCredentialID(from attestationObjectData: Data) -> Data? {
        do {
            guard let cbor = try? CBOR.decode([UInt8](attestationObjectData)) else {
                print("Failed to decode CBOR")
                return nil
            }

            guard case let CBOR.map(cborMap) = cbor else {
                print("CBOR root object is not a map")
                return nil
            }

            let key = CBOR.utf8String("authData")
            guard let authDataCBOR = cborMap[key],
                  case let CBOR.byteString(authDataBytes) = authDataCBOR else {
                print("Failed to find authData as byte string")
                return nil
            }

            let authData = Data(authDataBytes)

            guard authData.count >= 39 else {
                print("authData too short")
                return nil
            }

            let credentialIdLengthData = authData.subdata(in: 37..<(37 + 2))
            let credentialIdLength = credentialIdLengthData.withUnsafeBytes { ptr -> UInt16 in
                return ptr.load(as: UInt16.self).bigEndian
            }

            let credentialIdStart = 39
            let credentialIdEnd = credentialIdStart + Int(credentialIdLength)

            guard authData.count >= credentialIdEnd else {
                print("authData too short for credential ID")
                return nil
            }

            let credentialID = authData.subdata(in: credentialIdStart..<credentialIdEnd)
            return credentialID
        } catch {
            print("CBOR decoding failed with error: \(error)")
            return nil
        }
    }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let logger = Logger()
        guard let authorizationError = error as? ASAuthorizationError else {
            isPerformingModalRequest = false
            logger.error("Unexpected authorization error: \(error.localizedDescription)")
            return
        }
        logger.log("Error: \(error)")

        if authorizationError.code == .canceled {
            // Either the system doesn't find any credentials and the request ends silently, or the user cancels the request.
            // This is a good time to show a traditional login form, or ask the user to create an account.
            logger.log("Request canceled.")

            if isPerformingModalRequest {
                didCancelModalSheet()
            }
        } else {
            // Another ASAuthorization error.
            // Note: The userInfo dictionary contains useful information.
            logger.error("Error: \((error as NSError).userInfo)")
        }

        isPerformingModalRequest = false
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return authenticationAnchor!
    }

    func didFinishSignIn() {
        NotificationCenter.default.post(name: .UserSignedIn, object: nil)
    }

    func didCancelModalSheet() {
        NotificationCenter.default.post(name: .ModalSignInSheetCanceled, object: nil)
    }
    
    func base64UrlToBase64(_ base64Url: String) -> String {
        var base64 = base64Url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding to make it a multiple of 4
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        return base64
    }
    
}

