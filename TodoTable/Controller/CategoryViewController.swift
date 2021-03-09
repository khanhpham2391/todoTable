//
//  CategoryViewController.swift
//  TodoTable
//
//  Created by inmac on 27/02/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    
    
    //MARK: - TableView Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView,cellForRowAt: indexPath)
        if let categoryRow = categories?[indexPath.row] {
            cell.textLabel?.text = categoryRow.name
            cell.backgroundColor = UIColor(hexString: categoryRow.colour)
        } else {
            cell.textLabel?.text = "No Category added yet!"
            cell.backgroundColor = FlatSand()
        }
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    func saveData(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting from realm \(error)")
            }
            
        }
    }
    
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add New", style: .default) { (alertAction) in
            if textField.text == "" {
                return
            } else {
                let category = Category()
                category.name = textField.text!
                category.colour = UIColor(randomFlatColorOf: .light).hexValue()
                self.saveData(category: category)
            }
        }
        alert.addAction(action)
        alert.addTextField { (uiTextField) in
            uiTextField.placeholder = "Add Category"
            textField = uiTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
}

