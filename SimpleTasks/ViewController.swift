//
//  ViewController.swift
//  SimpleTasks
//
//  Created by Travis Marceau on 6/20/17.
//  Copyright © 2017 travisMarceau. All rights reserved.
//
//  Clear Simulator cache: xcrun simctl erase all

import UIKit
import RealmSwift

// MARK: Model

final class TaskList: Object {
    dynamic var text = ""
    dynamic var id = ""
    let items = List<Task>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Task: Object {
    dynamic var text = ""
    dynamic var completed = false
}

class ViewController: UITableViewController {
    
    var items = List<Task>()
    
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    func setupRealm() {
        let username = "t@travismarceau.com"
        let password = "dgEB9Gjy9R8T"
        
//        let username = "travis"
//        let password = "realm"
        
        SyncUser.logIn(with: .usernamePassword(username: username, password: password, register: false), server: URL(string: "http://192.241.211.145:9080")!) { user, error in
            guard let user = user else {
                fatalError(String(describing: error))
            }
            
            DispatchQueue.main.async {
                // Open Realm
                let configuration = Realm.Configuration(
                    syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://192.241.211.145:9080/~/realmtasks")!)
                )
                self.realm = try! Realm(configuration: configuration)
                
                // Show initial tasks
                func updateList() {
                    //self.items.realm == nil,
                    if let list = self.realm.objects(TaskList.self).first {
                        print("PASSED")
                        print(list)
                        self.items = list.items
                    }
                    else {
                        print("FAILED")
                        print(self.items.realm ?? "EMPTY")
                        
                        if !self.realm.isInWriteTransaction {
                            try! self.realm.write {
                                let list = TaskList()
                                list.id = "000002"
                                list.text = "Next List"
                                self.realm.add(list)
                            }
                            updateList()
                        }
                        
                    }
                    self.tableView.reloadData()
                }
                updateList()
                
                // Notify us when Realm changes
                self.notificationToken = self.realm.addNotificationBlock { _ in
                    updateList()
                }
            }
        }
    }
    
    deinit {
        notificationToken.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRealm()
    }
    
    func setupUI() {
        title = "My Tasks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
    }
    
    //MARK: UITableView
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.alpha = item.completed ? 0.5 : 1
        return cell
    }
    
    func add() {
        let alertController = UIAlertController(title: "New Task", message: "Enter Task Name", preferredStyle: .alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Task Name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
            let items = self.items
            try! items.realm?.write {
                items.insert(Task(value: ["text": text]), at: items.filter("completed = false").count)
            }
            
//            self.items.append(Task(value: ["text": text]))
//            self.tableView.reloadData()
        })
        present(alertController, animated: true, completion: nil)
    }
    
    
}

