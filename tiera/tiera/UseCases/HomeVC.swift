//
//  HomeVC.swift
//  tiera
//
//  Created by Christos Christodoulou on 02/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import UserNotifications

class HomeVC: UIViewController {

    @IBOutlet weak var selectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var stopCoffeeButton: UIButton!
    @IBOutlet weak var startCoffeeButton: FARoundedButton!
    @IBOutlet weak var scheduleCoffeeButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var prepareCoffeeButton: FARoundedButton!
    
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound];
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalNotification()
        scheduledLocalNotification()
        
        
    }
    
    func setupLocalNotification() {
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
    }
    
    func scheduledLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = "Coffee is getting ready"
        content.sound = UNNotificationSound.default
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false) //maybe this can be used as a reminder
    
        ///from userdefaults
        let date = Date(timeIntervalSinceNow: 600)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: NSCalendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date), repeats: false)

//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        ///Daily
//        let triggerDaily = Calendar.current.dateComponents([hour, .minute, .second], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)

        ///Weekly
//        let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)

        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
        })
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze",
                                                title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "UYLDeleteAction",
                                                title: "Delete", options: [.destructive])
    }


    @IBAction func startCoffeeTapped(_ sender: Any) {
        progressLabel.text = "Connecting ..."
        ///TODO: start the BT process...
    }
    
    @IBAction func prepareCoffeeTapped(_ sender: Any) {
        ///Start BT process to Open Tray to add the capsule and fill the water tank
        /// - parameters:
        /// - check water tank: 
        ///
    }
    
    @IBAction func cancelCoffeeTapped(_ sender: Any) {
        progressLabel.text = "Ready to connect!"
        //TODO: stop the connection
        //Maybe 
    }
    
    @IBAction func scheduleCoffeeTapped(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleSegue", sender: self)
    }
    
}
