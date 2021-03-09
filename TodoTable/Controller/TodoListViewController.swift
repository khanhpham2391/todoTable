//
//  ViewController.swift
//  TodoTable
//
//  Created by inmac on 25/02/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadData()
        }
    }
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // print(Realm.Configuration.defaultConfiguration.fileURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let hexColor = selectedCategory?.colour {
            
            let color = UIColor(hexString: hexColor) ?? FlatWhite()
            let contrastColor = ContrastColorOf(color, returnFlat: true)
            
            guard let navigationBar = navigationController?.navigationBar else {fatalError("navigation controller not exist")}
            
            navigationBar.barTintColor = UIColor(hexString: hexColor)
            navigationBar.tintColor = contrastColor
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
            
            title = selectedCategory!.name
            searchBar.barTintColor = color
        }
    }
    
    //MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let colour = UIColor(hexString: selectedCategory?.colour ?? "000000")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Item added yet!"
            cell.backgroundColor = FlatSand()
        }
        
        return cell
    }
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("Error updating item \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add button pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var uiTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add New", style: .default) { (UIAlertAction) in
            if uiTextField.text == "" {
                return
            } else {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write{
                            let item = Item()
                            item.title = uiTextField.text!
                            item.dateCreated = Date()
                            item.colour = RandomFlatColor().hexValue()
                            currentCategory.items.append(item)
                        }
                    } catch {
                        print("Error adding todo item")
                    }
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (UITextField) in
            UITextField.placeholder = "Add new item"
            uiTextField = UITextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true,completion: nil)
    }
    
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let todoItemForDeletion = todoItems?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(todoItemForDeletion)
                })
            } catch {
                print("Error deleting dotoItems \(error)")
            }
        }
    }
    
    //MARK: - Model Manipulation Method
    
    func loadData() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    }
}

//MARK: - search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title contains[cd] %@",searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            todoItems = todoItems?.filter("title contains[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
        } else {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        tableView.reloadData()
    }
}

