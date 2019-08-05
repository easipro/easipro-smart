//
//  MasterViewController.swift
//  EASIPRO-Home
//
//  Created by Raheel Sayeed on 8/5/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit
import AssessmentCenter
import SMART
import ResearchKit


class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil

    @IBOutlet weak var btnSubmitResults: UIBarButtonItem!
    
    var selectedForms: [ACForm]? = nil {
        didSet {
            btnSubmitResults.title = "-"
            questionnaireResponses.removeAll()
            tableView.reloadData()
        }
    }
    
    var questionnaireResponses = [QuestionnaireResponse]()


    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }
    
    
    func configureView() {
        title = SMARTClient.shared.patient?.sm_patientName ?? ""
    }


    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPROMIS" {
            
             let controller = (segue.destination as! UINavigationController).topViewController as! PROMISViewController
            controller.onSelectionCompletion = { forms in
                self.selectedForms = forms
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedForms?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell

        let form = selectedForms![indexPath.row]
        cell.lblCode.text = "LOINC: \(form.loinc ?? "-")"
        cell.lblTitle.text = form.title
        cell.lblCaption.text = "REQUESTED BY Dr JOHN DOE"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let form = selectedForms![indexPath.row]
        startSession(promisForms: [form])
    }

    
    

    @IBAction func loginAction(_ sender: Any) {
        
        let login = SMARTLoginController(title: "Login", publisher: "EASIPRO Home")
        present(login, animated: true, completion: nil)

    }
    
    @IBAction func submitResults(_ sender: Any) {
        
        if questionnaireResponses.isEmpty {
            showMsg(msg: "No Results generated")
            return
        }
        
        let reportViewController = ReportViewController(questionnaireResponses)
        let navigationController = UINavigationController(rootViewController: reportViewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
}



extension MasterViewController: ORKTaskViewControllerDelegate {
    
    
    func startSession(promisForms: [ACForm]?) {
        
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
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        if reason == .completed, let taskVC = taskViewController as? ACTaskViewController, let qresponse_json = taskVC.questionnaireResponseJSON {
            do {
                let datetime = DateTime.now
                let questionnaireResponse = try QuestionnaireResponse(json: qresponse_json)
                questionnaireResponse.authored = datetime
                questionnaireResponse.subject = try SMARTClient.shared.patient?.asRelativeReference()
                addResponse(qr: questionnaireResponse)
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
    
    func addResponse(qr: QuestionnaireResponse) {

        questionnaireResponses.append(qr)
        btnSubmitResults.title = "Submit Results (\(questionnaireResponses.count))"
    }
    
    
    
}


