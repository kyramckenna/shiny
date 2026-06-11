//
//  AuthenticatorInfo.swift
//  DaonFidoSampleRpApp
//
//  Created by Neil Johnston on 5/6/16.
//  Copyright © 2016 Daon. All rights reserved.
//
import Foundation

internal class AuthenticatorInfo : NSObject
{
    // MARK:- Properties
    
    internal var id : String
    internal var deviceid : String
    internal var created : Date
    internal var lastUsed : Date?
    internal var name : String
    internal var authDescription : String
    internal var vendorName : String
    internal var icon : String
    internal var status : String
    internal var fidoDeregistrationRequest : String
    internal var aaid : String
    
    // MARK:- JSON Keys
    
    private let jsonIdKey                           = "id"
    private let jsonCreatedKey                      = "created"
    private let jsonLastUsedKey                     = "lastUsed"
    private let jsonNameKey                         = "name"
    private let jsonDescriptionKey                  = "description"
    private let jsonVendorNameKey                   = "vendorName"
    private let jsonIconKey                         = "icon"
    private let jsonStatusKey                       = "status"
    private let jsonFidoDeregistrationRequestKey    = "fidoDeregistrationRequest"
    private let jsonAaidKey                         = "aaid"
    private let jsonDeviceCorrelationIdKey          = "deviceCorrelationId"
    
    // MARK:- Initialisation
    
    init(json: [String : Any]?)
    {
        self.id                         = ServerOperation.string(dictionary:json, key: jsonIdKey)
        self.deviceid                   = ServerOperation.string(dictionary:json, key: jsonDeviceCorrelationIdKey)
        self.name                       = ServerOperation.string(dictionary:json, key: jsonNameKey)
        self.authDescription            = ServerOperation.string(dictionary:json, key: jsonDescriptionKey)
        self.vendorName                 = ServerOperation.string(dictionary:json, key: jsonVendorNameKey)
        self.icon                       = ServerOperation.string(dictionary:json, key: jsonIconKey)
        self.status                     = ServerOperation.string(dictionary:json, key: jsonStatusKey)
        self.fidoDeregistrationRequest  = ServerOperation.string(dictionary:json, key: jsonFidoDeregistrationRequestKey)
        self.aaid                       = ServerOperation.string(dictionary:json, key: jsonAaidKey)
        
        self.created = Date()
        
        if (json != nil) {
            if let createdDate = ServerOperation.date(dictionary: json!, key: jsonCreatedKey) {
                self.created = createdDate
            }
            
            self.lastUsed = ServerOperation.date(dictionary: json!, key: jsonLastUsedKey)
        }
    }
    

}




