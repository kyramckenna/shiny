//
//  BaseNetworkResponse.swift
//  DaonFidoSampleRpApp
//
//  Copyright © 2018 Daon. All rights reserved.
//
import Foundation

internal class BaseNetworkResponse : NSObject
{
    // MARK:- Properties
    
    internal var sessionId : String?
    internal var error : ServerOperationError?
    internal var data = [String : Any]()
    
    // MARK:- JSON Keys
    
    private let jsonSessionIdKey = "sessionId"
    
    // MARK:- Initialisation
    
    override init() {
    }
    
    init(error : ServerOperationError?) {
        self.error = error
    }
    
    init(json: Any) {
        if let data = json as? [String : Any] {
            self.sessionId = data[jsonSessionIdKey] as? String
        }
    }
    
    func response() -> [String : Any] {
        return data
    }
}
