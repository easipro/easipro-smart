//
//  ReportViewController.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 8/2/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import Foundation
import UIKit
import SMART

class ReportViewController: UITableViewController {
    
    public final var questionnaireResponses: [QuestionnaireResponse]!
    
    public convenience init(_ responses: [QuestionnaireResponse]) {
        
        self.init(style: .grouped)
        self.questionnaireResponses = responses
        self.title = "QuestionnaireResponses"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf(_:)))
        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitToEHR(_:)))
    }
    
    @objc
    func submitToEHR(_ sender: Any) {
        
        guard let client = SMARTClient.shared.client else {
            showMsg(msg: "Server not found, Login to the FHIR server")
            return
        }
        
        let group = DispatchGroup()
        for q in questionnaireResponses {
            group.enter()
            q.create(client.server) { (error) in
                if let error = error {
                    print(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.showMsg(msg: "Submission Complete")
            self.tableView.reloadData()
        }

    }
    @objc
    func dismissSelf(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table View
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Completed"
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return questionnaireResponses != nil ? 1 : 0
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionnaireResponses?.count ?? 0
        
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "QCell")
        
        cell.accessoryType = .detailDisclosureButton
        let response = questionnaireResponses![indexPath.row]
        cell.textLabel?.text = "QuestionnaireResponse"
        cell.detailTextLabel?.text = response.sm_metaData
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let qr = questionnaireResponses![indexPath.row]
        let fhirViewer = FHIRViewController(qr)
        navigationController?.pushViewController(fhirViewer, animated: true)
    }
    
}

open class FHIRViewController: UIViewController {
    
    public final var resource: DomainResource?
    
    var textView: UITextView!
    
    
    convenience init(_ resource: DomainResource?) {
        
        self.init()
        self.resource = resource

    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let frame = view.frame
        textView = UITextView(frame: frame)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        let views = ["textView": textView as Any]
        view.sm_addVisualConstraint("H:|-[textView]-|", views)
        view.sm_addVisualConstraint("V:|-[textView]-|", views)
        
        
        if let json = resource?.sm_jsonString {
            textView.text = json
        }
    }
    
}



