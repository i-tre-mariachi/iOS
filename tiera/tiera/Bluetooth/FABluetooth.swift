//
//  FABluetooth.swift
//  tiera
//
//  Created by Christos Christodoulou on 03/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import Foundation
import CoreBluetooth

enum Manager {
    case centralManager
    case peripheralManager
}

// MARK: - Central Manager Protocols

// Conform to this protocol to WRITE
protocol KYBluetoothCentralWritable: class {
    func bluetooth(_ bluetooth: KYBluetooth, didWriteValueFor characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral, error: Error?)
}

// Conform to this protocol to READ
protocol KYBluetoothCentralReadable: class {
    func bluetooth(_ bluetooth: KYBluetooth, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
}

// Required bluetooth central protocol
protocol KYBluetoothCentralDelegate: class {
    func bluetooth(_ bluetooth: KYBluetooth, didChange state: TieraManagerState)
    func bluetooth(_ bluetooth: KYBluetooth, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    func bluetooth(_ bluetooth: KYBluetooth, didConnect peripheral: CBPeripheral)
    func bluetooth(_ bluetooth: KYBluetooth, didFail peripheral: CBPeripheral)
    func bluetooth(_ bluetooth: KYBluetooth, didDisconnect peripheral: CBPeripheral, error: Error?)
    func bluetooth(_ bluetooth: KYBluetooth, didDiscover characteristics:[CBCharacteristic], error: Error?)
}

// MARK: - Peripheral Manager Protocols
protocol KYBluetoothPeripheralDelegate: class {
    func bluetooth(_ bluetooth: KYBluetooth, didChange state: TieraManagerState)
    func bluetooth(_ bluetooth: KYBluetooth, didStartAdvertising peripheral: CBPeripheralManager, error: Error?)
    func bluetooth(_ bluetooth: KYBluetooth, didAdd service: CBService, error: Error?)
    func bluetooth(_ bluetooth: KYBluetooth, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)
    func bluetooth(_ bluetooth: KYBluetooth, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    func bluetooth(_ bluetooth: KYBluetooth, peripheralManager: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    func bluetooth(_ bluetooth: KYBluetooth, peripheralManager: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    func bluetooth(_ bluetooth: KYBluetooth, IsReadyToUpdateSubscribers peripheral: CBPeripheralManager)
}

class KYBluetooth : NSObject
{
    static let State = "state"
    static let StateKey = "stateKey"
    
    var serviceUUID: CBUUID?
    var characteristicsUUID = [CBUUID]()
    
    weak var centralDelegate: KYBluetoothCentralDelegate?
    weak var peripheralDelegate: KYBluetoothPeripheralDelegate?
    
    weak var writableDelegate: KYBluetoothCentralWritable?
    weak var readableDelegate: KYBluetoothCentralReadable?
    
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    var selectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var targetCharacteristic: CBCharacteristic?
    var manager: Manager
    
    init(manager: Manager){
        self.manager = manager
        super.init()
        
        if self.manager == .centralManager{
            setupCentralManager()
        }
        else{
            setupPeripheralManager()
        }
    }
    
    private func setupCentralManager (){
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .default) , options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    private func setupPeripheralManager (){
        peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.global(qos: .default), options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
    
    // MARK: - Commands in CentralManager
    public func startScan (){
        if let serviceUUID = serviceUUID{
            centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    public func stopScan (){
        centralManager?.stopScan()
    }
    
    public func isScanning() -> Bool?{
        guard let centralManager = centralManager else {return nil}
        return centralManager.isScanning
    }
    
    // Connect to selected peripheral
    public func connectTo(peripheral: CBPeripheral)
    {
        selectedPeripheral = peripheral
        
        if let selectedPeripheral = selectedPeripheral
        {
            selectedPeripheral.delegate = self;
            centralManager?.connect(selectedPeripheral, options: nil)
        }
    }
    
    // Discover services of selected peripheral
    public func discoverServices(peripheral: CBPeripheral){
        if let serviceUUID = serviceUUID{
            peripheral.discoverServices([serviceUUID])
        }
    }
    
    // Write Value
    public func writeValue(characteristic: CBCharacteristic, data: Data){
        
        if characteristic.properties.contains(.write) {
            targetCharacteristic = characteristic
            selectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    // Read Value
    public func readValue(characteristic: CBCharacteristic){
        
        if (characteristic.properties.contains(.read)){
            selectedPeripheral?.readValue(for: characteristic)
        }
    }
    
    // Retrieve connected peripherals
    public func retrieveConnectedPeripherals(withServices: [CBUUID]) -> [CBPeripheral]
    {
        guard let centralManager = centralManager else {return []}
        guard let serviceUUID = serviceUUID else {return []}
        return centralManager.retrieveConnectedPeripherals(withServices:[serviceUUID])
    }
    
    // Retrieve known peripherals
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral]
    {
        guard let centralManager = centralManager else {return []}
        return centralManager.retrievePeripherals(withIdentifiers: identifiers)
    }
    
    // Cancel peripheral
    public func cancelPeripheralConnection(peripheral: CBPeripheral)
    {
        centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    public func tearDown(){
        if manager == .centralManager{
            // Clear everything
            centralManager = nil
            selectedPeripheral = nil
            targetService = nil
            targetCharacteristic = nil
        }
        else {
            peripheralDelegate = nil
            peripheralManager?.delegate = nil
            peripheralManager = nil
            
        }
    }
    
    // MARK: - Commands in PeripheralManager
    
    public func startAdvertising(_ advertisementData: [String : Any]?){
        peripheralManager?.startAdvertising(advertisementData)
    }
    
    public func stopAdvertising(){
        peripheralManager?.stopAdvertising()
    }
    
    public func isAdvertising () -> Bool{
        guard let peripheralManager = peripheralManager else {return false}
        return peripheralManager.isAdvertising
    }
    
    public func add(_ service: CBMutableService){
        peripheralManager?.add(service)
    }
    
    public func remove(_ service: CBMutableService){
        peripheralManager?.remove(service)
    }
    
    public func removeAllServices (){
        peripheralManager?.removeAllServices()
    }
    
    public func setDesiredConnectionLatency(_ latency : CBPeripheralManagerConnectionLatency, for central: CBCentral){
        peripheralManager?.setDesiredConnectionLatency(latency, for: central)
    }
    
    public func respond(to request: CBATTRequest, withResult result: CBATTError.Code){
        peripheralManager?.respond(to: request, withResult: result)
    }
    
    public func updateValue(_ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool{
        
        guard let peripheralManager = peripheralManager else {return false}
        return peripheralManager.updateValue(value, for: characteristic, onSubscribedCentrals: centrals)
    }
    
}

// MARK: - CBCentralManagerDelegate
extension KYBluetooth : CBCentralManagerDelegate
{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        let state: TieraManagerState
        
        switch central.state {
        case .poweredOn:
            state = .TieraManagerStatePoweredOn
        case .poweredOff:
            state = .TieraManagerStatePoweredOff
        case .resetting:
            state = .TieraManagerStateResetting
        case .unsupported:
            state = .KYManagerStateUnsupported
        case .unauthorized:
            state = .TieraManagerStateUnauthorized
        case .unknown:
            state = .TieraManagerStateUnknown
            
        }
        
        // Update the views that dont have any relation with Bluetooth
        NotificationCenter.default.post(name: Notification.Name(KYBluetooth.State), object: nil, userInfo:[ KYBluetooth.StateKey : state ])
        
        // Update handlers/views that have direct connection to Bluetooth (e.g. tap to Connect)
        centralDelegate?.bluetooth(self, didChange: state)
    }
    
    // Notify the discovered peripherals
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralDelegate?.bluetooth(self, didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    // Notify that didConnect
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralDelegate?.bluetooth(self, didConnect: peripheral)
    }
    
    // Notify that didFailToConnect
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        centralDelegate?.bluetooth(self, didFail: peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // This method is invoked when a peripheral connected via the connect(_:options:) method is disconnected.
        // If the disconnection was not initiated by cancelPeripheralConnection(_:), the cause is detailed in error.
        
        centralDelegate?.bluetooth(self, didDisconnect: peripheral, error: error)
    }
}

// MARK: - CBPeripheralDelegate
extension KYBluetooth: CBPeripheralDelegate {
    
    // didDiscoverServices
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        targetService = services.first
        
        if let service = services.first {
            targetService = service
            
            // Array of characteristics
            peripheral.discoverCharacteristics(characteristicsUUID, for: service)
        }
    }
    
    // didDiscoverCharacteristics
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        // Notify discovered characteristics
        centralDelegate?.bluetooth(self, didDiscover: characteristics, error: error)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // Notify that we write for characteristic
        self.writableDelegate?.bluetooth(self, didWriteValueFor: characteristic, forPeripheral:peripheral, error: error)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Notify that we read
        self.readableDelegate?.bluetooth(self, didUpdateValueFor: characteristic, error: error)
    }
}

extension KYBluetooth{
    convenience init (manager: Manager, serviceUUID: CBUUID, characteristicsUUID:[CBUUID], centralDelegate: KYBluetoothCentralDelegate? = nil, peripheralDelegate: KYBluetoothPeripheralDelegate? = nil, writableDelegate: KYBluetoothCentralWritable? = nil, readableDelegate: KYBluetoothCentralReadable? = nil) {
        
        self.init(manager: manager)
        
        self.serviceUUID = serviceUUID
        self.characteristicsUUID = characteristicsUUID
        self.centralDelegate = centralDelegate
        self.peripheralDelegate = peripheralDelegate
        self.writableDelegate = writableDelegate
        self.readableDelegate = readableDelegate
    }
}
// MARK: - CBPeripheralManagerDelegate
extension KYBluetooth: CBPeripheralManagerDelegate{
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        let state: TieraManagerState
        
        switch peripheral.state {
        case .poweredOn:
            state = .TieraManagerStatePoweredOn
        case .poweredOff:
            state = .TieraManagerStatePoweredOff
        case .resetting:
            state = .TieraManagerStateResetting
        case .unsupported:
            state = .KYManagerStateUnsupported
        case .unauthorized:
            state = .TieraManagerStateUnauthorized
        case .unknown:
            state = .TieraManagerStateUnknown
            
        }
        
        // Update the views that dont have any relation with Bluetooth
        NotificationCenter.default.post(name: Notification.Name(KYBluetooth.State), object: nil, userInfo:[ KYBluetooth.StateKey : state ])
        
        // Update handlers/views that have direct connection to Bluetooth (e.g. tap to Connect)
        peripheralDelegate?.bluetooth(self, didChange: state)
    }
    
    // Notify that peripheralManagerDidStartAdvertising
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        peripheralDelegate?.bluetooth(self, didStartAdvertising: peripheral, error: error)
    }
    
    // Notify that didAdd service
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        peripheralDelegate?.bluetooth(self, didAdd: service, error: error)
    }
    
    // Notify that didSubscribeTo characteristic
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        peripheralDelegate?.bluetooth(self, central: central, didSubscribeTo: characteristic)
    }
    
    // Notify that didUnsubscribeFrom characteristic
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        peripheralDelegate?.bluetooth(self, central: central, didUnsubscribeFrom: characteristic)
    }
    
    // Notify that didReceiveRead request
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        peripheralDelegate?.bluetooth(self, peripheralManager: peripheral, didReceiveRead: request)
        
    }
    
    // Notify that didReceiveWrite requests
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        peripheralDelegate?.bluetooth(self, peripheralManager: peripheral, didReceiveWrite: requests)
    }
    
    // Notify that peripheralManagerIsReady toUpdateSubscribers
    public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        peripheralDelegate?.bluetooth(self, IsReadyToUpdateSubscribers: peripheral)
    }
}
