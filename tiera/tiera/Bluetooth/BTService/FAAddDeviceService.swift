//
//  FAAddDeviceService.swift
//  tiera
//
//  Created by Christos Christodoulou on 15/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol AddDeviceProtocol {
    
    func addDevice(_ addDevice: FAAddDeviceService, didChange state : TieraManagerState)
    func addDevice(_ addDevice: FAAddDeviceService, didDiscover peripheral: CBPeripheral, rssi RSSI: NSNumber)
    func addDevice(_ addDevice: FAAddDeviceService, didConnect peripheral: CBPeripheral)
    func addDevice(_ addDevice: FAAddDeviceService, didWriteValue peripheral: CBPeripheral, error: Error?)
    func addDevice(_ addDevice: FAAddDeviceService, didWriteValueFor characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral, error: Error?)
    func addDevice(_ addDevice: FAAddDeviceService, didDisconnect peripheral: CBPeripheral, error: Error?)
//    func addCollar(_ addCollar: FAAddDeviceService, doNetworkCall device: KYCollar?)
}

private let macAddressCharacteristicUUID = CBUUID(string:"A011")            // Read MAC address
private let imeiGsmCharacteristicUUID = CBUUID(string:"A012")               // Read IMEI from GSM
private let registrationStatusCharacteristicUUID = CBUUID(string:"A014")    // Write registration status
private let deviceRegistrationServiceUUID = CBUUID(string:"A010")           // Device Registration Service

class FAAddDeviceService : NSObject, KYBluetoothCentralDelegate, KYBluetoothCentralWritable, KYBluetoothCentralReadable{

    private var bluetooth : FABluetooth?
//    var ioc_collarController : KYCollarControllerProtocol!
//    var collar : KYCollar?
    var characteristicToWrite: CBCharacteristic?
    var delegate: AddDeviceProtocol?
    
    func start(delegate: AddDeviceProtocol?){
        // Initialize new device
        
        self.delegate = delegate
        bluetooth = FABluetooth(manager: .centralManager, serviceUUID: serviceUUID, characteristicsUUID: characteristicsUUID, centralDelegate: self, readableDelegate: self)
    }
    
    func startScan (){
        bluetooth?.startScan()
    }
    
    func stopScan(){
        bluetooth?.stopScan()
    }
    
    func connectTo(peripheral: CBPeripheral)
    {
        bluetooth?.connectTo(peripheral: peripheral)
    }
    
    func cancel(peripheral: CBPeripheral)
    {
        bluetooth?.cancelPeripheralConnection(peripheral: peripheral)
    }
    
    func discoverServices(peripheral: CBPeripheral)
    {
        bluetooth?.discoverServices(peripheral: peripheral)
    }
    
    func writeData(isSucess:Bool) {
        
        // Data to write depending of the web request
        let data = self.data(isSuccess:isSucess)
        
        if let characteristic = self.characteristicToWrite{
            self.bluetooth?.writeValue(characteristic: characteristic, data: data)
        }
    }
    
    //MARK: - KYBluetoothCentralDelegate listeners
    func bluetooth(_ bluetooth: FABluetooth, didChange state: TieraManagerState) {
        if state == .TieraManagerStatePoweredOn {
            // Process with scanning
            startScan()
        }
        
        delegate?.addDevice(self, didChange: state)
    }
    
    func bluetooth(_ bluetooth: FABluetooth, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.addDevice(self, didDiscover: peripheral, rssi: RSSI)
    }
    
    func bluetooth(_ bluetooth: FABluetooth, didConnect peripheral: CBPeripheral) {
        delegate?.addDevice(self, didConnect: peripheral)
    }
    func bluetooth(_ bluetooth: FABluetooth, didFail peripheral: CBPeripheral) {}
    
    func bluetooth(_ bluetooth: FABluetooth, didDisconnect peripheral: CBPeripheral, error: Error?) {
        delegate?.addDevice(self, didDisconnect: peripheral, error: error)
    }
    func bluetooth(_ bluetooth: FABluetooth, didDiscover characteristics:[CBCharacteristic], error: Error?) {
        for characteristic in characteristics{
            
            if characteristic.uuid == registrationStatusCharacteristicUUID{
                characteristicToWrite = characteristic
                continue
            }
            
            bluetooth.readValue(characteristic: characteristic)
        }
    }
    
    //MARK: - KYBluetoothWritable listeners
    //    func bluetooth(_ bluetooth: KYBluetooth, didWriteValue peripheral: CBPeripheral, error: Error?) {
    //        delegate?.addCollar(self, didWriteValue: peripheral, error: error)
    //    }
    func bluetooth(_ bluetooth: FABluetooth, didWriteValueFor characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.addDevice(self, didWriteValue: peripheral, error: error)
    }
    
    //MARK: - KYBluetoothReadble listeners
    func bluetooth(_ bluetooth: FABluetooth, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic.uuid == macAddressCharacteristicUUID{
            
            if let data = characteristic.value{
                let macAddress = String(data: data, encoding: String.Encoding.utf8)
//                collar?.serialNumber = macAddress
            }
        }
        else if characteristic.uuid == imeiGsmCharacteristicUUID{
            if let data = characteristic.value{
                let gsmImei = String(data: data, encoding: String.Encoding.utf8)
//                collar?.gsmImei = gsmImei
            }
        }
        
        ///Final call before disc
//        if let _ = collar?.serialNumber, let _ = collar?.gsmImei{
//            // Notify to perform web call in
//            delegate?.addDevice(self, doNetworkCall: collar)
//        }
    }
}

extension FAAddDeviceService: BluetoothService {
    var characteristicsUUID: [CBUUID]{
        return [macAddressCharacteristicUUID, imeiGsmCharacteristicUUID, registrationStatusCharacteristicUUID]
    }
    
    var serviceUUID: CBUUID {
        return deviceRegistrationServiceUUID
    }
    
    // - Registration Status = 0x0A or 10d means success.
    // - Registration Status = 0x9A or 154d means failure.
    func data(isSuccess: Bool) -> Data{
        
        let bytes :[UInt8] = isSuccess ? [0x0A] : [0x9A]
        return Data(bytes:bytes)
    }
}
