//
//  VerifyAuthenticationResponse
//  DaonFidoSampleRpApp
//
//  Copyright © 2023 Daon. All rights reserved.
//

internal class VerifyCombinedAuthenticationResponse : BaseNetworkResponse
{
    // MARK:- Properties
    
    internal var singleShotFidoAuthenticationResponse : String?
    internal var stepupAuthenticationRequest : String? //[String : Any]?
    internal var stepUpFidoAuthenticationRequestId : String?
    internal var fidoResponseCode : Int?
    internal var fidoResponseMsg : String?
    
    // MARK:- JSON Keys
    
    private let jsonSingleShotFidoAuthenticationResponseKey = "singleShotFidoAuthenticationResponse"
    private let jsonStepUpFidoAuthenticationRequest = "stepUpFidoAuthenticationRequest"
    private let jsonStepUpFidoAuthenticationRequestId = "stepUpFidoAuthenticationRequestId"
    private let jsonFidoResponseCodeKey             = "fidoResponseCode"
    private let jsonFidoResponseMsgKey              = "fidoResponseMsg"
    
    // MARK:- Initialisation
    
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any] {
            self.singleShotFidoAuthenticationResponse = jsonRepresentation[jsonSingleShotFidoAuthenticationResponseKey] as? String
            self.fidoResponseCode           = jsonRepresentation[jsonFidoResponseCodeKey] as? Int
            self.fidoResponseMsg            = jsonRepresentation[jsonFidoResponseMsgKey] as? String
            self.stepupAuthenticationRequest  = jsonRepresentation[jsonStepUpFidoAuthenticationRequest] as? String
            self.stepUpFidoAuthenticationRequestId = jsonRepresentation[jsonStepUpFidoAuthenticationRequestId] as? String
        }
    }
    
}
