//
//  GetPolicyResponse.swift
//  DaonFidoSampleRpApp
//
//  Copyright © 2018 Daon. All rights reserved.
//

import Foundation

internal class GetPolicyResponse : BaseNetworkResponse
{
    internal var id : String?
    internal var type : String?
    internal var policy : String?
    
    private let jsonPolicyInfoKey = "policyInfo"
    private let jsonIdKey = "id"
    private let jsonTypeKey = "type"
    private let jsonPolicyKey = "policy"
    
    
    override init(error: ServerOperationError?)
    {
        super.init(error: error)
    }
  
    override init(json: Any)
    {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any]
        {
            if let policyInfo = jsonRepresentation[jsonPolicyInfoKey] as? [String : String]
            {
                id = policyInfo[jsonIdKey]
                type = policyInfo[jsonTypeKey]
                policy = policyInfo[jsonPolicyKey]
            }
        }
    }

}
