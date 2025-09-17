//
//  VerifyAuthenticationResponse
//  DaonFidoSampleRpApp
//
//  Copyright © 2018 Daon. All rights reserved.
//

internal class VerifyAuthenticationResponse : BaseNetworkResponse
{
    // MARK:- Properties
    
    internal var fidoAuthenticationResponse : String?
    internal var fidoResponseCode : Int?
    internal var fidoResponseMsg : String?

    
    // MARK:- JSON Keys
    
    private let jsonFidoAuthenticationResponseKey   = "fidoAuthenticationResponse"
    private let jsonFidoResponseCodeKey             = "fidoResponseCode"
    private let jsonFidoResponseMsgKey              = "fidoResponseMsg"
        
    // MARK:- Initialisation
    
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any] {
            self.fidoAuthenticationResponse = jsonRepresentation[jsonFidoAuthenticationResponseKey] as? String
            self.fidoResponseCode           = jsonRepresentation[jsonFidoResponseCodeKey] as? Int
            self.fidoResponseMsg            = jsonRepresentation[jsonFidoResponseMsgKey] as? String
            
            // Patch incorrect fido.uaf.safetynet value from RP server
            self.fidoAuthenticationResponse = self.fidoAuthenticationResponse?.replacingOccurrences(of: "null", with: "")
        }
    }
    
}
