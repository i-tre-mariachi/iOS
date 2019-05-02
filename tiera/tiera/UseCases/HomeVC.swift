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
import tieraViewModel

import ReSwift

import CoreBluetooth//TODO: move to the implementation when is done


class HomeVC: UIViewController {

    @IBOutlet weak var batteryDateLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
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
    
    // 1 - acts as a declarative data source
    var tableDataSource: TableDataSource<UITableViewCell, String>?
    
    ///init ViewModel
    private var homeViewModel: HomeViewModel!
    
    ///TODO: To be placed in the BT Relevant view
    var centralManager: CBCentralManager!
    let tieraServiceCBUUID = CBUUID(string: "0x180D")
    let aCharacteristicCBUUID = CBUUID(string: "2A37")
    let bCharacteristicCBUUID = CBUUID(string: "2A38")
    var tieraPeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultValues()
        setupLocalNotification()
        
        setupBT() ///TODO: To be placed in the BT Relevant view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scheduledLocalNotification()
        
        // 2
        store.subscribe(self) {
            $0.select {
                $0.homeState
            }
        }
        
        /// Updating the State (This updates the store manually if the navigation back arrow was used)
        store.dispatch(RoutingAction(destination: .home))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 3
        store.unsubscribe(self)
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
        
        ///TODO: keep until we are sure if we want to reschedule or not.
        ///Daily
//        let triggerDaily = Calendar.current.dateComponents([hour, .minute, .second], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        ///Weekly
//        let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)

        let identifier = "UYLLocalNotification" //Maybe place it to the constants
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
        })
        
        /// N/A currently actions keep for further use
//        let snoozeAction = UNNotificationAction(identifier: "Snooze",
//                                                title: "Snooze", options: [])
//        let deleteAction = UNNotificationAction(identifier: "UYLDeleteAction",
//                                                title: "Delete", options: [.destructive])
        
        
        //TODO: this needs debug to be sure if we need it or not
        ///Change the isTIeraPrepared to false when coffee is completed (and maybe notify user for replace the capsule and fill water)
//        Defaults[.isTieraPrepared] = false
    }
    
    func trayLocalNotification() {
        if Defaults[.coffeeCleanTrayCounter] == 5 {
            let content = UNMutableNotificationContent()
            content.title = "Don't forget"
            content.body = "Coffee is getting ready!"
            content.sound = UNNotificationSound.default
            
            let identifier = "UYLLocalNotification" //Maybe place it to the constants
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    // Something went wrong
                    print(error)
                }
                let okAction = UNNotificationAction(identifier: "ok",
                                                    title: "Ok", options: [])
            })
            
            ///On success reset the counter
            Defaults[.coffeeCleanTrayCounter] = 0
        }
    }

    @IBAction func startCoffeeTapped(_ sender: Any) {
        progressLabel.text = "Connecting ..."
        ///Initialize the ViewModel
        self.homeViewModel = HomeViewModel(progressLabel: self.progressLabel.text!, startCoffeeButtonLabel: (startCoffeeButton.titleLabel?.text)!, scheduleCoffeeButtonLabel: (scheduleCoffeeButton.titleLabel?.text)!)
        
        ///TODO: start the BT process...
        startCoffeeProcess()
        
        ///Store the number of completed coffees made, might need it for life expectance of the tiera to run diagnostics or so?
        Defaults[.coffeeCounter] += 1
        
        ///Update the counter to empty the liquid tray after each 5 coffes made, alert the user on success and after tap ok reset the counter to 0
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
        
        addDevice.start(delegate: self as? AddDeviceProtocol)//TODO:
        
        if Defaults[.isTieraPrepared] {
            //TODO: throw a message it is already prepared
            return
        } else {
            ///on success set isTieraPrepared key to TRUE
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
        ///TODO: check which one is tapped otherwise take the default one.
        if Defaults[.coffeeDose] == ristrettoDoseUnit {
            Defaults[.coffeeDose] = ristrettoDoseUnit
        } else if Defaults[.coffeeDose] == singleDoseUnit {
            Defaults[.coffeeDose] = singleDoseUnit
        } else {
            Defaults[.coffeeDose] = lungoDoseUnit
        }
    }
    
    ///TODO: Bluetooth Implementation to be move to another ViewController
    /// Bluetooth related implementation
    private func setupBT() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func startCoffeeProcess() {
        print("startCoffeeProcess: scanForPeripherals")
        centralManager.scanForPeripherals(withServices: nil)
//        centralManager.scanForPeripherals(withServices: [tieraServiceCBUUID])
    }
    
}


extension HomeVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state
        {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        tieraPeripheral = peripheral
        tieraPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(tieraPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to: \(peripheral)")
        tieraPeripheral.discoverServices(nil)
    }
    
    
}

extension HomeVC: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case aCharacteristicCBUUID:
            print(characteristic.value ?? "no value")
            let optionsToPrepareCoffee = prepareCoffee(from: characteristic)
            progressLabel.text = optionsToPrepareCoffee
        case bCharacteristicCBUUID:
            let br = bytesReceived(from: characteristic)
            onSocReceived(soc: br)///function to update UI with the number calculated and other similar ones
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            progressLabel.text = "something went wrong please retry..."
        }
    }
    
    ///Add the logic to start the coffee and other options
    private func prepareCoffee(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }


    private func bytesReceived(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            //  Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            //  Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    func onSocReceived(soc: Int) {
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral: \(peripheral)")
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect: \(peripheral)")
    }
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState")
    }
}


// MARK: - StoreSubscriber
extension HomeVC: StoreSubscriber {
    func newState(state: HomeState) {
        // 4
        tableDataSource = TableDataSource(cellIdentifier:"TitleCell", models: state.homeTitles) {cell, model in
            cell.textLabel?.text = model
            cell.textLabel?.textAlignment = .center
            return cell
        }
        
//        tableView.dataSource = tableDataSource
//        tableView.reloadData()
    }
}

//extension HomeVC: UITableViewDelegate {
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var routeDestination: RoutingDestination = .home
//        switch(indexPath.row) {
//        case 0: routeDestination = .home
//        case 1: routeDestination = .schedule
//        default: break
//        }
//
//        store.dispatch(RoutingAction(destination: routeDestination))
//    }
//}
