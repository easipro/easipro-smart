//
//  Extensions.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 8/1/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import Foundation
import UIKit
import SMART



extension UIViewController {
    
    func showMsg(msg: String) {
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: "EASIPRO", message: msg, preferredStyle: .alert)
        alertViewController.addAction(alertAction)
        present(alertViewController, animated: true, completion: nil)
    }
}


extension QuestionnaireResponse {
    
    var sm_identifier: String {
        return id?.string != nil ? "ID: #\(String(describing: id!.string))" : "ID: -NA-"
    }
    var sm_title: String {
        return "Title"
    }
    
    var sm_coding: String {
        return identifier == nil ? "LOINC: \(String(describing: identifier!.value))" : "Code: -NA-"
    }
    
    var sm_completionStatus: String? {
        return "status"
    }
    
    var sm_metaData: String {
        return "\(sm_identifier) \(sm_coding)"
    }
    
    
}

extension DomainResource {
    
    var sm_jsonString: String? {
        do {
            let dictionary = try asJSON()
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? nil
        } catch {
            return nil
        }
    }
    
}

extension Patient {
    
    var sm_patientName: String {
        return humanName!
    }
    
    public func sm_MRNumber() -> String {
        
        if let identifier = identifier {
            
            let filtered = identifier.filter({ (iden) -> Bool in
                if let mrCode = iden.type?.coding?.filter({ (coding) -> Bool in
                    return coding.code?.string == "MR"
                }) {
                    return mrCode.count > 0
                }
                return false
            })
            
            if filtered.count > 0, let mrIdentifier = filtered.first {
                return "MRN: \(mrIdentifier.value!.string.uppercased())"
            }
        }
        return "MRN: NA"
    }
}

extension Practitioner {
    
    var sm_Name: String {
        return "Dr. \(name!.first!.human!)"
    }
}

extension UIView {
    
    func sm_addVisualConstraint(_ visualFormat: String,_ vs: [String:Any]) {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: [], metrics: nil, views: vs))
    }
}




