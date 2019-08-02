//
//  MasterViewController.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 8/1/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit
import AssessmentCenter

class MasterViewController: UITableViewController {

    var forms: [ACForm]?
    var selectedForms = [ACForm]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        addSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @IBAction func refreshPROMIS(_ sender: Any) {
        
        SMARTClient.shared.acClient?.listForms(loinc: true) { [weak self] (forms) in
            self?.forms = forms
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let form = forms![indexPath.row]
        cell.textLabel!.text = form.loinc
        cell.detailTextLabel?.text = form.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addForm(forms![indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        removeForm(forms![indexPath.row])
        
    }
    
    func addForm(_ form: ACForm) {
        
        if !selectedForms.contains(form) {
            selectedForms.append(form)
        }
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            let d = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            d?.promisForms = selectedForms
            d?.tableView.reloadData()
        }
        
        
    }
    
    func removeForm(_ form: ACForm) {
        
        if selectedForms.contains(form) {
            selectedForms.removeAll { (f) -> Bool in
                return f == form
            }
        }
        if let split = splitViewController {
            let controllers = split.viewControllers
            let d = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
            d?.promisForms = selectedForms
            d?.tableView.reloadData()
        }
    }


    


}



extension MasterViewController: UISearchControllerDelegate {
    
    func addSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
    }
}
