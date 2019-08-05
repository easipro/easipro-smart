

//
//  PROMISViewController.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 8/5/19.
//  Copyright © 2019 Boston Children's Hospital. All rights reserved.
//

import UIKit
import AssessmentCenter

class PROMISViewController: UITableViewController {
    
    public var onSelectionCompletion: ((_ forms: [ACForm]?) -> Void)?

    @IBOutlet weak var BtnSelected: UIBarButtonItem!
    
    var forms: [ACForm]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEditing(true, animated: false)

        
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        
        guard let ips = tableView.indexPathsForSelectedRows, let frms = forms else {
            
            dismiss(animated: false, completion: nil)
            return
        }
        let selected = ips.map { frms[$0.row] }
        onSelectionCompletion?(selected)
        dismiss(animated: false, completion: nil)

    }
    
    func updateSelection() {
        let count = tableView.indexPathsForSelectedRows?.count ?? 0
        BtnSelected.title = "Selected \(count)"

    }
    
    @IBAction func btnUnselectAll(_ sender: Any) {
        self.tableView.reloadData()
        updateSelection()
        
    }
    @IBAction func fetchPROMIS(_ sender: Any) {
        
        SMARTClient.shared.acClient?.listForms(loinc: true) { [weak self] (forms) in
            self?.forms = forms
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PROMISCell", for: indexPath)
        let form = forms![indexPath.row]
        cell.textLabel?.text = form.loinc
        cell.detailTextLabel?.text = form.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateSelection()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
