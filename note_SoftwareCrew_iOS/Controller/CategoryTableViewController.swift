//
//  AppDelegate.swift
//  note_SoftwareCrew_iOS
//
//  Created by Kirna on 13/09/21.
//

import UIKit
import CoreData
import  CoreLocation
class CategoryTableViewController: UITableViewController {
    
    var locationManager:CLLocationManager? = CLLocationManager()
    var userLocation:CLLocation!
    var userLat = Double()
    var userLong = Double()
    var notebooks:[Notebook] = []
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.purple
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext
        getAllNotebooks()
        checkForAllowLocation()
    }
    //MARK :- Buttion actions
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        let alertBox = UIAlertController(title: "Sort By", message: "", preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "Date", style: .default, handler: { alert -> Void in
            self.getAllNotebooks()
            self.tableView.reloadData()
        }))
        alertBox.addAction(UIAlertAction(title: "Ascending Order", style: .default, handler: { alert -> Void in
            self.getAllNotebooksByTitle()
            self.tableView.reloadData()
        }))
        alertBox.addAction(UIAlertAction(title: "Descending order", style: .default, handler: { alert -> Void in
            self.getAllNotebooksByTitleDesc()
            self.tableView.reloadData()
        }))
        
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alertBox, animated: true, completion: nil)
    }
    
    @IBAction func AddNotesBtn(_ sender: UIBarButtonItem) {
        let alertBox = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alertBox.addAction(UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            let textField = alertBox.textFields![0] as UITextField
            if (textField.text?.isEmpty == false) {
                let notebookSaved = self.addNotebook(notebookName: textField.text!)
                if (notebookSaved == true) {
                    self.getAllNotebooks()
                    self.tableView.reloadData()
                }
            }
        }))
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertBox.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Enter category name"
        })
        
        
        self.present(alertBox, animated: true, completion: nil)
        
    }
    
    // MARK: Getting data from database
    func getAllNotebooks() {
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        do {
            self.notebooks = try context.fetch(fetchRequest)
        }
        catch {
            print("Error")
        }
    }
    
    func getAllNotebooksByTitle() {
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            self.notebooks = try context.fetch(fetchRequest)
        }
        catch {
            print("Error")
        }
    }
    
    func getAllNotebooksByTitleDesc() {
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        do {
            self.notebooks = try context.fetch(fetchRequest)
        }
        catch {
            print("Error")
        }
    }
    
    func addNotebook(notebookName:String) -> Bool {
        let notebook = Notebook(context: self.context)
        notebook.name = notebookName
        notebook.setValue(Date(), forKey:"dateCreated")
        do {
            try self.context.save()
            return true
            
        }
        catch {
            print("error")
        }
        
        return false
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = notebooks[indexPath.row].name!
        return cell
    }
    //MARK:- Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let i = indexPath.row
            let notebookToDelete = notebooks[i]
            print(notebookToDelete.name!)
            // remove from array
            notebooks.remove(at: i)
            // remove from databas
            self.context.delete(notebookToDelete)
            do {
                try self.context.save()
                print("Deleted!")
            }
            catch {
                print("error")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        else if editingStyle == .insert {
            
        }
    }
    
    
    // MARK: - Navigation Stack
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showNotesSegue") {
            print("calling PREPARE function")
            let notesVC = segue.destination as! NotesTableViewController
            let i = (self.tableView.indexPathForSelectedRow?.row)!
            notesVC.notebook = notebooks[i]
        }
    }
  //MARK :- Check for location permission
    
    func checkForAllowLocation(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied {
            print("denied by user")
           
        }
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager?.requestAlwaysAuthorization()
            print(" got authorizedWhenInUse")
            if(userLat == 0.0){
                self.locationManager!.startUpdatingLocation()
            }
        }
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("got authorizedAlways")
            if(userLat == 0.0){
                self.locationManager!.startUpdatingLocation()
            }
        }
    }
}
