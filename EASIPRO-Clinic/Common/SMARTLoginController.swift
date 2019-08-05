//
//  SMARTLoginController.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 8/1/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit
import Foundation


// options
let fhirserverbaseURL = ""
let viewtitle = "PROF"
let loginTitle = "LOGIN"
let hospitalName =         "SMART Hospital"


open class SMARTLoginController: UIViewController  {
    
    var publisher: String?
    
    weak var statuslbl : UILabel?
    
    open internal(set) var loginButton : UIButton?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupViews()
    }
    
    convenience init(title: String? = nil, publisher: String? = nil) {
        self.init(nibName:nil, bundle:nil)
        self.title = title
        self.publisher = publisher
        modalPresentationStyle = .formSheet
        
    }
    
    func setupViews() {
        let userlbl = SMARTLoginController.titleLabel()
        let cancelBtn = cancelButton()
        userlbl.numberOfLines = 0
        userlbl.adjustsFontSizeToFitWidth = true
        userlbl.lineBreakMode = .byWordWrapping
        let btn = LoginButton()
        let lbl = SMARTLoginController.titleLabel()
        userlbl.text = SMARTClient.shared.practitioner?.name?.first?.human ?? ""
        userlbl.textColor = UIColor.lightGray
        statuslbl = userlbl
        
        let v = [
            "cbtn"  : cancelBtn,
            "btn"   : btn,
            "tlbl"  : lbl,
            "user"  : userlbl
            ] as [String: Any]
        view.addSubview(cancelBtn)
        view.addSubview(btn)
        view.addSubview(lbl)
        view.addSubview(userlbl)
        
        
        let centerY = NSLayoutConstraint(item: btn,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0.0);

        view.sm_addVisualConstraint("V:|[cbtn(55)]", v)
        view.sm_addVisualConstraint("H:|[cbtn]", v)
        view.sm_addVisualConstraint("H:|-50-[btn]-50-|", v)
        view.sm_addVisualConstraint("H:|-50-[tlbl]-50-|", v)
        view.sm_addVisualConstraint("H:|-50-[user]-50-|", v)
        view.sm_addVisualConstraint("V:[btn(55)]", v)
        view.sm_addVisualConstraint("V:[btn]-40-[user]", v)
        view.sm_addVisualConstraint("V:[tlbl]-20-[btn]", v)
        view.sm_addVisualConstraint("V:[user]-30-|", v)
        view.addConstraint(centerY);
        
    }
    

    func LoginButton() -> UIButton {
        
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let btn = UIButton(type: .system)
        btn.frame = frame
        btn.setTitle(loginTitle, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(loginTitle, for: .normal)
        btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        btn.addTarget(self, action: #selector(login(_:)), for: UIControl.Event.touchUpInside)
        
        return btn
    }
    
    
    func cancelButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 70, height: 55)
        btn.setTitle("Cancel", for: .normal)
        btn.addTarget(self, action: #selector(cancel(_ :)), for: .touchUpInside)
        return btn
    }
    
    @objc
    func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    class func titleLabel() -> UILabel {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.text =  Bundle.main.object(forInfoDictionaryKey: "SM_APP_TITLE") as? String
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }
    
    
    
    @objc func login(_ sender: Any) {
        
        SMARTClient.shared.authorize { [weak self] (success, error) in
            if let error = error {
                print(error as Any)
            }
            
            if success {
                DispatchQueue.main.async {
                    let name = (SMARTClient.shared.practitioner != nil) ? SMARTClient.shared.practitioner?.name?.first?.human : SMARTClient.shared.patient?.humanName
                    self?.statuslbl?.text = name
                    self?.dismiss(animated: true, completion: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    if let error = error {
                        self?.statuslbl?.text = "Authorization Failed. Try again \(error.asOAuth2Error.localizedDescription)"
                    }
                }
            }
        }
    }
    
}
