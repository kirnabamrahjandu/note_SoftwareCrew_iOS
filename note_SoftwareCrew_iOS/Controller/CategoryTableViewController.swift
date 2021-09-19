//
//  AppDelegate.swift
//  note_SoftwareCrew_iOS
//
//  Created by Kirna on 13/09/21.
//

import UIKit
import CoreData
class CategoryTableViewController: UITableViewController {
    
    var notebooks:[Notebook] = []
    // MARK:  CoreData variables
    var context:NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.purple
        // initialize CoreData variables
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext
        // setup array of notebooks
        getAllNotebooks()
    }

    // MARK: - Table view data source
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        let alertBox = UIAlertController(title: "Sort By", message: "", preferredStyle: .alert)
        
        
        // 2. Add Save and Cancel buttons
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
        
        
        
        // 4. show the alertbox
        self.present(alertBox, animated: true, completion: nil)
    }

    @IBAction func AddNotesBtn(_ sender: UIBarButtonItem) {
    // 1. Create a popup
    let alertBox = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
    
    
    // 2. Add Save and Cancel buttons
    alertBox.addAction(UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
        let textField = alertBox.textFields![0] as UITextField
        
        
        if (textField.text?.isEmpty == false) {
            let notebookSaved = self.addNotebook(notebookName: textField.text!)
            if (notebookSaved == true) {
                // reload the table
                self.getAllNotebooks()
                self.tableView.reloadData()
            }
        }
    }))
    alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    // 3. Add a textbox
    alertBox.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
        textField.placeholder = "Enter category name"
    })
    
    
    // 4. show the alertbox
    self.present(alertBox, animated: true, completion: nil)
    
        }

    // MARK: database helper functions
      func getAllNotebooks() {
        
        // setup array of notebooks
               let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
               do {
                   
                   self.notebooks = try context.fetch(fetchRequest)
               }
               catch {
                   print("Error fetching notebooks from database")
        }
        
 
      }
    
      func getAllNotebooksByTitle() {
          //fetchRequest.predicate = NSPredicate(format: "notebook.name = %@", notebook.name)
          // setup array of notebooks
          let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
          fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
          do {
              
              self.notebooks = try context.fetch(fetchRequest)
          }
          catch {
              print("Error fetching notebooks from database")
          }
      }
    
      func getAllNotebooksByTitleDesc() {
          // setup array of notebooks
          let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
          fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
          do {
              
              self.notebooks = try context.fetch(fetchRequest)
          }
          catch {
              print("Error fetching notebooks from database")
          }
      }
     
    func addNotebook(notebookName:String) -> Bool {
          let notebook = Notebook(context: self.context)
          notebook.name = notebookName
          notebook.setValue(Date(), forKey:"dateCreated")
          
          //notebook.dateCreated = Date()
          
          do {
              try self.context.save()
              print("notebook saved!")
              return true
              
          }
          catch {
              print("error while trying to save a new notebook")
          }
          
          return false
          
      }

   override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notebooks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = notebooks[indexPath.row].name!
        return cell
    }
   
    // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
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
            print("error while commiting notebook delete")
                                 }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showNotesSegue") {
        print("calling PREPARE function")
        let notesVC = segue.destination as! NotesTableViewController
        let i = (self.tableView.indexPathForSelectedRow?.row)!
        notesVC.notebook = notebooks[i]
        }
    }
}
