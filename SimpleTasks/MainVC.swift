
import UIKit
import RealmSwift

// MARK: Model

// Task list object to hold the collection of tasks
// Allow for multiple task lists in future implementation
final class TaskList: Object {
    dynamic var text = ""
    dynamic var id = ""
    let items = List<Task>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// task object declaration -- primary object in this app
final class Task: Object {
    dynamic var text = ""
    dynamic var completed = false
    dynamic var realDate = Date()
    dynamic var priority = ""
}

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = List<Task>()
    
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    func setupRealm() {
        
        // credentials for demo realm
        let username = "t@travismarceau.com"
        let password = "dgEB9Gjy9R8T"
        
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
                    
                    // if task lists exist in realm, use the first
                    // do not update during active write transactions
                    if let list = self.realm.objects(TaskList.self).first {
                        self.items = list.items
                        if !self.realm.isInWriteTransaction {
                            self.determineSortOrder()
                        }
                    }
                    // if no task list, populate realm with a base list
                    // do not update during active write transactions
                    else {
                        if !self.realm.isInWriteTransaction {
                            try! self.realm.write {
                                let list = TaskList()
                                list.id = "000001"
                                list.text = "Base List"
                                self.realm.add(list)
                            }
                            updateList()
                        }
                        
                    }
                    self.tableView.reloadData()
                }
                updateList()
                
                // update view on realm change
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
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get a reusable cell - get the associated item - update cell content - return cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            let item = items[indexPath.row]
            print(indexPath.row)
            cell.updateUI(task: item)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // move row from one position to another in realm
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! items.realm?.write {
            items.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
    
    // delete task from realm list when appropriate UI action is taken
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let item = items[indexPath.row]
                realm.delete(item)
            }
        }
    }
    
    // trigger segue to launch detail view of selected task
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        performSegue(withIdentifier: "DetailVC", sender: item)
    }
    
    // segue validation of appropriate arguments
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailVC {
            if let taskSender = sender as? Task {
                destination.task = taskSender
            }
        }
    }
    
    // actions for add and segment selector buttons + outlet for segment selector
    @IBAction func addButton(_ sender: Any) { add() }
    @IBOutlet weak var sortControl: UISegmentedControl!
    @IBAction func sortOrder(_ sender: Any) {
        determineSortOrder()
    }
    
    // determine which sort type was selected and call sort with appropriate parameters
    func determineSortOrder() {
        switch sortControl.selectedSegmentIndex {
        case 0: sort(sortBy: "realDate", asc: true)
            break
        case 1: sort(sortBy: "priority", asc: false)
            break
        case 2: sort(sortBy: "completed", asc: true)
            break
        default: break
        }
    }
    
    // re-write the entire list in realm according to sort parameters
    // I do wonder if there is a better way to do this, and impact of larger list sizes
    func sort(sortBy: String, asc: Bool) {
        if let list = self.realm.objects(TaskList.self).first {
            try! list.realm?.write {
                list.items.replaceSubrange(0..<list.items.count, with: List(list.items.sorted(byKeyPath: sortBy, ascending: asc)))
            }
        }
    }
    
    // alert for new entry and write contents directly to server
    // priority will be populated according to server function
    // date will default to current datetime
    // completed defaults to false
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
                // at has been made obsolete, as insertion will occur according to sort
                items.insert(Task(value: ["text": text]), at: items.filter("completed = false").count)
            }
        })
        present(alertController, animated: true, completion: nil)
    }
    
}

