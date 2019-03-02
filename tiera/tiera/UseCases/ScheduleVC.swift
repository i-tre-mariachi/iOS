//
//  ScheduleVC.swift
//  tiera
//
//  Created by Christos Christodoulou on 02/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import UserNotifications

class ScheduleVC: UIViewController {

    @IBOutlet weak var closeModalButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scheduleTextField: UITextField!
    
//    private var dateTimePicker: UIDatePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDatePicker()
        setupTapGesture()
    }
    
    func setupDatePicker() {
        let dateTimePicker = UIDatePicker()
        dateTimePicker.datePickerMode = .dateAndTime
        dateTimePicker.addTarget(self, action: #selector(ScheduleVC.dateChanged(datePicker:)), for: .valueChanged)
        
        scheduleTextField.inputView = dateTimePicker
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")
        scheduleTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func closeModalTapped(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //TODO: enabled after we have a valid date
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
}
