//
//  DetailViewController.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 8/1/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit
import SMART
import AssessmentCenter
import ResearchKit


public class DetailViewController: UITableViewController {
    

    public var promisForms: [ACForm]?
    
    public var questionnaireResponses = [QuestionnaireResponse]()
    
    @IBOutlet weak var lblMRN: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var btnPatient: UIButton!
    
    weak var btnSubmit: UIButton?
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }
    
    
    func configureView() {
        
        title = SMARTClient.shared.practitioner?.sm_Name ?? ""
        btnPatient.setTitle("\(SMARTClient.shared.patient?.sm_patientName ?? "select patient")  ▼" , for: .normal)
        lblDOB.text = SMARTClient.shared.patient?.humanBirthDateMedium
        lblMRN.text = SMARTClient.shared.patient?.sm_MRNumber() ?? "MRN: N/A"
    }

    override public func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()

        let nibFooter = UINib(nibName: "SessionActionView", bundle: nil)
        tableView.register(nibFooter, forHeaderFooterViewReuseIdentifier: "SessionActionView")
    }

    @IBAction func emptySelection(_ sender: Any) {
        
        promisForms = nil
        questionnaireResponses.removeAll()
        updateButton()
        tableView.reloadData()
    }
    
    @IBAction func showLogin(_ sender: Any) {
        
        let login = SMARTLoginController(title: "Login", publisher: "EASIPRO Clinic")
        present(login, animated: true, completion: nil)
    }
    
    @objc
    func submitResults(_ sender: Any) {
        
        if questionnaireResponses.isEmpty {
            showMsg(msg: "No Results generated")
            return
        }
        
        let reportViewController = ReportViewController(questionnaireResponses)
        let navigationController = UINavigationController(rootViewController: reportViewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func startSession(_ sender: Any) {
        
        guard promisForms?.count ?? 0 > 0, let acClient = SMARTClient.shared.acClient else { return }
        
        acClient.forms(acforms: promisForms!) { (completedForms) in
            
            guard let completed = completedForms else { return }
            
            let proSessionViewControllers = completed.map({ (form) -> ACTaskViewController in
                let taskViewController = ACTaskViewController(acform: form, client: SMARTClient.shared.acClient!, sessionIdentifier: "sessionId")
                taskViewController.delegate = self
                return taskViewController
            })
            
            let navigationController = UINavigationController()
            navigationController.setViewControllers(proSessionViewControllers, animated: true)
            navigationController.isNavigationBarHidden = true
            navigationController.isToolbarHidden = true
            present(navigationController, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    // MARK: - Table View
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "LOINC: PROMIS"
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return promisForms?.count ?? 0
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        let form = promisForms![indexPath.row]
        cell.textLabel!.text = form.loinc
        cell.detailTextLabel?.text = form.title
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SessionActionView") as! SessionActionView
        cell.btnStart.addTarget(self, action: #selector(startSession(_:)), for: .touchUpInside)
        cell.submitResults.addTarget(self, action: #selector(submitResults(_:)), for: .touchUpInside)
        btnSubmit = cell.submitResults
        updateButton()
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return promisForms?.count ?? 0 > 0 ? 120 : 0
    }
    
    func updateButton() {
        btnSubmit?.setTitle("Submit Results (\(questionnaireResponses.count))", for: .normal)
    }
    
    @IBAction func patientSelector(_ sender: Any) {
    }
    
    
    
}

extension DetailViewController: ORKTaskViewControllerDelegate {
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        if reason == .completed, let taskVC = taskViewController as? ACTaskViewController, let qresponse_json = taskVC.questionnaireResponseJSON {
            do {
                let datetime = DateTime.now
                let questionnaireResponse = try QuestionnaireResponse(json: qresponse_json)
                questionnaireResponse.authored = datetime
                questionnaireResponse.subject = try SMARTClient.shared.patient?.asRelativeReference()
                questionnaireResponses.append(questionnaireResponse)
                updateButton()
            }
            catch {
                print(error)
            }
        }
        
        if let nav = taskViewController.navigationController {
            if nav.viewControllers.count == 1 {
                taskViewController.dismiss(animated: true, completion: nil)
            }
            else {
                nav.popViewController(animated: true)
            }
        }
    }
}


