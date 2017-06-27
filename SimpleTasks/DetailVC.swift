
import UIKit
import RealmSwift

class DetailVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
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
        
//        dateFormatter.dateStyle = .short
//        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "d/M/yy H:mm"
//        if let convertedStartDate = dateFormatter.date(from: task.date) {
//            datePicker.setDate(convertedStartDate, animated: true)
//        }
        
        updateLabels()
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        let strDate = dateFormatter.string(from: datePicker.date)
        dateLabel.text = strDate
        updateLabels()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[priorityComponent][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabels()
    }
    
    func updateLabels(){
        let priority = pickerData[priorityComponent][priorityPicker.selectedRow(inComponent: priorityComponent)]
        priorityLabel.text = priority
    }
    
    @IBAction func toggleCompleted(_ sender: Any) {
        let item = task
        try! item.realm?.write {
            item.completed = !item.completed
        }
    }
    
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
