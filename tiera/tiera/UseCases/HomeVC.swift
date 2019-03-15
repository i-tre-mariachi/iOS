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
import tieraCommon

class HomeVC: UIViewController {

    @IBOutlet weak var doseSegmentedControl: UISegmentedControl!
    @IBOutlet weak var stopCoffeeButton: UIButton!
    @IBOutlet weak var startCoffeeButton: FARoundedButton!
    @IBOutlet weak var scheduleCoffeeButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var prepareCoffeeButton: FARoundedButton!
    
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound];
   
    ///Initialize the addService
    /// - parameters:
    /// delayBetweenScans is 0.5
    lazy var addDevice: FAAddDeviceService = {
        let addDevice = FAAddDeviceService()
        return addDevice
    }()
    private let delayBetweenScans = 0.5
    
//    var scanViewController: FAScanViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultValues()
        setupLocalNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scheduledLocalNotification()
    }
    
    func setupDefaultValues() {
        Defaults[.coffeeDose] = singleDoseUnit
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
        content.body = "Coffee is getting ready!"
        content.sound = UNNotificationSound.default
        
        guard let date = Defaults[.isScheduledAt] else { return }//Date(timeIntervalSinceNow: 600)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: NSCalendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date), repeats: false)
        
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
        
        //TODO: this needs debug to be sure if we need it or not
        ///Change the isTIeraPrepared to false when coffee is completed (and maybe notify user for replace the capsule and fill water)
//        Defaults[.isTieraPrepared] = false
    }


    @IBAction func startCoffeeTapped(_ sender: Any) {
        progressLabel.text = "Connecting ..."
        ///TODO: start the BT process...
        
        ///Keep the number of completed coffees made might need it for life expectance of the tiera to run diagnostics or so?
        Defaults[.coffeeCounter] += 1
        
        ///Update the counter to prepare the liquid tray after the reach of 5 alert and on success reset the counter to 0
        /// - parameters:
        /// coffeeCleanTrayCounter max number is 5
        Defaults[.coffeeCleanTrayCounter] = Defaults[.coffeeCleanTrayCounter] + 1
        
        ///Change the isTIeraPrepared to false when coffee is completed (and maybe notify user for replace the capsule and fill water)
        Defaults[.isTieraPrepared] = false
    }
    
    @IBAction func prepareCoffeeTapped(_ sender: Any) {
        ///Start BT process to Open Tray to add the capsule and fill the water tank
        /// - parameters:
        /// - check water tank: 
        ///
        
        if Defaults[.isTieraPrepared] {
            //TODO: throw message is already prepared
            return
        } else {
            ///on success set isTIeraPrepared key to TRUE
            Defaults[.isTieraPrepared] = true
        }
        
    }
    
    @IBAction func cancelCoffeeTapped(_ sender: Any) {
        progressLabel.text = "Ready to connect!"
        //TODO: stop the connection
        
        //Maybe 
    }
    
    @IBAction func scheduleCoffeeTapped(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleSegue", sender: self)
    }
    
    @IBAction func doseSegmentedControlTapped(_ sender: Any) {
        if Defaults[.coffeeDose] == singleDoseUnit {
            Defaults[.coffeeDose] = lungoDoseUnit
        } else {
            Defaults[.coffeeDose] = singleDoseUnit
        }
    }
}
