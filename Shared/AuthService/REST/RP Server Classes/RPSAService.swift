
import SystemConfiguration
import Foundation
import SwiftCBOR

internal class RPSAService : NSObject {
    
    static let shared: RPSAService = RPSAService()
    
    // Resources
    private let KServerResourceAccounts                     = "accounts"
    private let KServerResourceCredentials                  = "credentials"
    private let KServerResourceSessions                     = "sessions"
    private let KServerResourceAuthRequests                 = "authRequests"
    private let KServerRegistrationRequest = "register"
    
    // Response data keys
    private let jsonEmailAddressKey                 = "emailAddress"
    private let jsonEmailKey                        = "email"
    private let jsonPasswordKey                     = "password"
    private let jsonFirstNameKey                    = "firstName"
    private let jsonLastNameKey                     = "lastName"
    
    public var sessionId : String?
    private var requestId : String?
    
    var request : String?
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
    // createUser in IDX
    func createAccount(first: String, last: String, username: String, password: String, completion: @escaping (CreateAccountResponse) -> ()) {
        
        var params = Dictionary<String, String>()
        
        params[jsonFirstNameKey]              = first
        params[jsonLastNameKey]               = last
        params[jsonEmailKey]                  = username
        params[jsonPasswordKey]               = password
        params["makeCredentialRequested"] = "true"
        
        post(resource: KServerResourceAccounts, body: params, completion: { (json, raw) in
            
            let response = CreateAccountResponse(json: json)
            
            Constants.User.CREDENTIAL_REQUEST_CHALLENGE = response.w3cMakeCredentialRequest!
            self.requestId = response.makeCredentialRequestId!
            Constants.User.CREDENTIAL_REQUEST_ID = self.requestId!
            Constants.User.accountId = response.accountId!
            
            print("ID : \(Constants.User.CREDENTIAL_REQUEST_ID)")
            print("CHALLENGE : \(Constants.User.CREDENTIAL_REQUEST_CHALLENGE)")
            
            completion(response)
            
        }) { (error) in
            
            completion(CreateAccountResponse(error: error))
        }
    }
    
    
//    I am sending
//    
//    ✅ 1. clientDataJSON
//    A JSON-encoded structure, then UTF-8 encoded into binary.
//    Contains:
//    type: "webauthn.create" (indicates registration)
//    challenge: Base64url-encoded challenge string (sent by the server and must be verified)
//    origin: Origin of the relying party (e.g., "https://emea-rp.identityx-cloud.com")
//    crossOrigin: Whether the request is cross-origin
//  
//    ✅ 2. attestationObject (may be optional or empty if .none is set)
//    A CBOR-encoded binary blob that includes:
//    Authenticator data (authData)
//    Attestation statement (attStmt) (may be empty if .none was set)
//    It includes the public key, AAGUID, credential ID, and potentially attestation info.
//    This is what the server parses to extract the new public key and store it with the credential ID.
//
//    ✅ 3. credentialID
//    A randomly generated identifier for the new key pair.
//    You store this with the user's record to identify which key to challenge in future authentication.

    // NOTE:
//    Apple's native passkey implementation in iOS, iPadOS, and macOS does not support passkey attestation. This is a deliberate design choice prioritizing user privacy and ease of use over attestation-based device verification.Attestation, while a security measure, can sometimes create friction or technical limitations that Apple has opted to avoid in its passkey implementation.
//
  /*  This method sends
    
    {
      "makeCredentialResponseV1": {
        "response": {
          "attestationObject": "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YViY22zdT3Jmeb5FtazrDDNOiwBlKpsNhcIknNZUo+flzM1dAAAAAPv8MAcVTk7MjAtuAgVX170AFINtjIUZhTGJ7muMQDgOgtdt5ZgZpQECAyYgASFYIMfKxoljmtT+/oxDxtLfdRb8aWlf+bEO91RmG60rOTAZIlgg6C/5QgaY/a15w8DzhZjZQnxgGLMnp6cKAKJj1HBz3fo=",
          "clientDataJSON": "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiV0lCdkN0Z09BakQ0MmlYWk1GT3JmQSIsIm9yaWdpbiI6Imh0dHBzOi8vZW1lYS1ycC5pZGVudGl0eXgtY2xvdWQuY29tIn0="
        },
        "id": "g22MhRmFMYnua4xAOA6C123lmBk=",
        "type": "public-key"
      }
    }
   
   The attestation is not "FIDO2(WEBAUTHN)_PACKED_ATTESTATION" like in the WebAuth version
   What's possible on iOS:
   You can request "packed" attestation via the ASAuthorizationPlatformPublicKeyCredentialProvider by setting the attestationPreference to .direct or .indirect.
   However, Apple intentionally strips out attestation certificates on most devices (especially for passkeys, which are synced across iCloud Keychain).
   The result is that you get a packed attestation format, but it often contains empty or anonymized certificate chains, making it effectively useless for strong device verification.
   
   */
  
    func updateCredentials(handler: @escaping (String?, Error?) -> Void) {
        
        let credentialId = Constants.User.credentialID
        let attestationObject = Constants.User.AttestationObject
        let clientDataJSON = Constants.User.clientDataJSON
        
        // Base64 encode clientDataJSON string
        var base64clientDataJSON = ""
        if let data = clientDataJSON.data(using: .utf8) {
            base64clientDataJSON = data.base64EncodedString()
            print("Base64 encoded clientDataJSON: \(base64clientDataJSON)")
        } else {
            print("Failed to convert clientDataJSON string to data")
        }
        
        // Construct w3cMakeCredentialResponse dictionary with correct structure
        let w3cMakeCredentialResponseDict: [String: Any] = [
            "makeCredentialResponseV1": [
                "id": credentialId,
                "type": "public-key",
                "response": [
                    "clientDataJSON": base64clientDataJSON,
                    "attestationObject": attestationObject
                ]
            ]
        ]
        
        // Serialize dictionary to JSON string
        var w3cMakeCredentialResponseString = ""
        if let jsonData = try? JSONSerialization.data(withJSONObject: w3cMakeCredentialResponseDict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            w3cMakeCredentialResponseString = jsonString
        } else {
            print("Failed to serialize w3cMakeCredentialResponse dictionary to JSON string")
        }
        
        // Build final body dictionary
        let body: [String: Any] = [
            "makeCredentialRequestId": Constants.User.CREDENTIAL_REQUEST_ID,
            "name": "browser",
            "w3cMakeCredentialResponse": w3cMakeCredentialResponseString
        ]
        
        print("Request body:")
        print(body)
        
        post(resource: KServerResourceCredentials, body: body, completion: { (json, raw) in
            print(json)
            handler("Success", nil)
        }) { (error) in
            handler(error.localizedDescription, error)
        }
    }
    
    // requestAuthentication(resource: resource, handler: handler)
    /* Payload we receive
    {
      "getAssertionRequestV1": {
        "challenge": "DXVhB96FihMSRcmpEC8vQA",
        "allowCredentials": [
          {
            "type": "public-key",
            "id": "okfO3N8Fu7CchCWEj5rDuDuqAj8A_icIcwv8ZD5N-kw"
          }
        ],
        "userVerification": "preferred"
      },
      "assertionExtensions": {
        "exts": true
      }
    }*/
    
    func requestAuthentication(completion: @escaping (RequestAuthenticationResponse) -> ()) {

        var resource = KServerResourceAuthRequests
        let accountId = Constants.User.accountId
        
        if accountId != "" {
            resource = "\(resource)?accountId=\(accountId)"
        }
        
        get(resource: resource, completion: { (json, raw) in

            let response = RequestAuthenticationResponse(json: json)
            
            Constants.User.authenticationRequestId = response.authenticationRequestId!
            Constants.User.CREDENTIAL_REQUEST_CHALLENGE = response.challenge!
            Constants.User.credentialID = response.credentialId!
            
            completion(response)

        }) { (error) in
            completion(RequestAuthenticationResponse(error: error))
        }
    }
    
    func postSessions(handler: @escaping (String?, Error?) -> Void) {
        
        let clientDataJSON = Constants.User.clientDataJSON
        
        // Base64 encode clientDataJSON string
        var base64clientDataJSON = ""
        if let data = clientDataJSON.data(using: .utf8) {
            base64clientDataJSON = data.base64EncodedString()
            print("Base64 encoded clientDataJSON: \(base64clientDataJSON)")
        } else {
            print("Failed to convert clientDataJSON string to data")
        }
        
        // Construct w3cMakeCredentialResponse dictionary with correct structure
        let w3cMakeCredentialResponseDict: [String: Any] = [
            "getAssertionResponseV1": [
                "assertion": [
                    "id": Constants.User.credentialID,
                    "type": "public-key",
                    "response": [
                        "authenticatorData": Constants.User.authenticatorData,
                        "clientDataJSON": base64clientDataJSON,
                        "signature": Constants.User.signature,
                        "userHandle": Constants.User.userID
                    ]
                ]
            ]
        ]
        
        // Serialize dictionary to JSON string
        var w3cMakeCredentialResponseString = ""
        if let jsonData = try? JSONSerialization.data(withJSONObject: w3cMakeCredentialResponseDict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            w3cMakeCredentialResponseString = jsonString
        } else {
            print("Failed to serialize w3cMakeCredentialResponse dictionary to JSON string")
        }
        
        // Build final body dictionary
        let body: [String: Any] = [
            "authenticationRequestId": Constants.User.authenticationRequestId,
            "w3cAuthenticationResponse": w3cMakeCredentialResponseString
        ]
        
        post(resource: KServerResourceSessions, body: body, completion: { (json, raw) in
            print(json)
            handler("Success", nil)
        }) { (error) in
            handler(error.localizedDescription, error)
        }
    }


    
    var server = Constants.Server.Url 
    
    // HTTP Post and Get
    
    private func post(resource : String, body: Dictionary<String, Any>, completion: @escaping (Any, String) -> (), failure: @escaping (ServerOperationError) -> ()) {
        
        let operation = ServerOperation(postUrl: server,
                                        resourceName: resource,
                                        body: body,
                                        session: sessionId,
                                        completion: completion,
                                        failure: failure)
        
        operation.start()
    }
    
    private func get(resource : String, completion: @escaping (Any, String) -> (), failure: @escaping (ServerOperationError) -> ()) {
        let operation = ServerOperation(getUrl: server,
                                        resourceName: resource,
                                        session: sessionId,
                                        completion: completion,
                                        failure: failure)
        
        operation.start()
    }
}

