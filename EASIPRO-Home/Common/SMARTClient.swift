//
//  SMARTClient.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 8/1/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import Foundation
import SMART
import AssessmentCenter



public class SMARTClient: NSObject {
    
    public static let shared = SMARTClient()
    
    public var smart_settings: [String: String]?
    
    public var assessment_center_credetials: [String: String]?
    
    public var smart_endpoint: URL?
    
    public lazy var client: SMART.Client? = {
        guard let smart_endpoint = smart_endpoint, let settings = smart_settings else {
            print("Client needs base url")
            return nil
        }
        return Client(baseURL: smart_endpoint, settings: settings)
    }()
    
    var acClient: ACClient?
    
    public var patient: Patient?
    
    public var practitioner: Practitioner?
    
    
    
    override private init() {
        
        
    }
    
    
    public func authorize(callback: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        guard let client = client else { return }
        
        client.authorize(callback: { [unowned self] (patientResource,  error) in
            
            if let p = patientResource {
                self.patient = p
            }
            
            if let idToken = self.client!.server.idToken, let decoded = self.base64UrlDecode(idToken), let profile = decoded["profile"] as? String {
                let components = profile.components(separatedBy: "/")
                let resourceType = components[0]
                let resourceId   = components[1]
                if resourceType == "Practitioner" {
                    Practitioner.read(resourceId, server: self.client!.server, callback: { (resource, ferror) in
                        if let practitioner = resource as? Practitioner {
                            self.practitioner = practitioner
                            callback(true, nil)
                        }
                    })
                }
                else if resourceType == "Patient" {
                    Patient.read(resourceId, server: self.client!.server, callback: { (resource, ferror) in
                        if let patient = resource as? Patient {
                            if self.patient == nil || self.patient!.id != patient.id {
                                self.patient = patient
                            }
                            callback(self.patient != nil, nil)
                        }
                    })
                }
                else {
                    
                    callback(self.patient != nil, nil)
                }
            }
            else {
                callback(error == nil, error)
            }
        })
    }
    
    
    private func base64UrlDecode(_ value: String) -> [String: Any]? {
        let comps = value.components(separatedBy: ".")
        
        var base64 = comps[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        let data =  Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        guard let json = try? JSONSerialization.jsonObject(with: data!, options: []), let payload = json as? [String: Any] else {
            print("error decoding")
            return nil
        }
        
        return payload
    }
    
}
