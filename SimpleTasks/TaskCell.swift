//
//  TaskCell.swift
//  SimpleTasks
//
//  Created by Travis Marceau on 6/22/17.
//  Copyright © 2017 travisMarceau. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    var tapAction: ((UITableViewCell) -> Void)?
    
    @IBOutlet weak var taskDate: UILabel!
    @IBOutlet weak var taskText: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(task: Task) {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "d/M/yy H:mm"
        let strDate = dateFormatter.string(from: task.realDate)
        taskDate.text = strDate
        taskText.text = task.text
        if task.completed {
            checkImage.alpha = 1
        } else {
            checkImage.alpha = 0.1
        }
    }

}
