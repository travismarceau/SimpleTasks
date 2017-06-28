
import UIKit
import RealmSwift

class DetailVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    // details page setup includes many little items / inputs
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var priorityPicker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toggle: UISwitch!
    
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    private var _task: Task!
    
    let dateFormatter = DateFormatter()
    let pickerData = [["!!! High !!!","!! Normal !!","! Low !"]]
    let priorityComponent = 0
    
    var task: Task {
        get {
            return _task
        } set {
            _task = newValue
        }
    }
    
    // on load, populate current task values
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.addTarget(self, action: #selector(DetailVC.datePickerChanged), for: UIControlEvents.valueChanged)
        
        priorityPicker.delegate = self as UIPickerViewDelegate
        priorityPicker.dataSource = self as UIPickerViewDataSource
        
        textField.text = task.text
        
        if(!task.completed) {
            toggle.setOn(false, animated: true)
        }
        
        if let initialIndex = pickerData[0].index(of: task.priority) {
            priorityPicker.selectRow(initialIndex, inComponent: priorityComponent, animated: false)
        } else {
            priorityPicker.selectRow(1, inComponent: priorityComponent, animated: false)
        }
        
        datePicker.setDate(task.realDate, animated: true)
        updateLabels()
    }
    
    // update labels when new date is selected
    func datePickerChanged(datePicker:UIDatePicker) {
        updateLabels()
    }
    
    // return number of picker items (always one here)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    // return number of picker items (number of priority options)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    // return name of specific row in picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[priorityComponent][row]
    }
    
    // update labels when a new row is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabels()
    }
    
    // refresh the labels with current picker values
    func updateLabels(){
        let priority = pickerData[priorityComponent][priorityPicker.selectedRow(inComponent: priorityComponent)]
        priorityLabel.text = priority
        
        dateFormatter.dateFormat = "d/M/yy H:mm"
        let strDate = dateFormatter.string(from: datePicker.date)
        dateLabel.text = strDate
    }
    
    // execute completion on realm
    // consider making this consistent with pickers -- update on change versus on save
    @IBAction func toggleCompleted(_ sender: Any) {
        let item = task
        try! item.realm?.write {
            item.completed = !item.completed
        }
    }
    
    // save the newly selected values to realm -- pop back to list view
    @IBAction func saveButton(_ sender: Any) {
        let priority = pickerData[priorityComponent][priorityPicker.selectedRow(inComponent: priorityComponent)]
        let inDate = datePicker.date
        let newText = textField.text
        print("save!")
        let item = task
        try! item.realm?.write {
            item.text = newText!
            item.realDate = inDate
            item.priority = priority
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
