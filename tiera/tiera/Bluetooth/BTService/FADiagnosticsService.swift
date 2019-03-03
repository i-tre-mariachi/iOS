//
//  FADiagnosticsService.swift
//  tiera
//
//  Created by Christos Christodoulou on 03/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DiagnosticsServiceProtocol {
    func diagnosticsService(_ diagnosticsService: KYDiagnosticsService, didChange state : TieraManagerState)
    func diagnosticsService(_ diagnosticsService: KYDiagnosticsService, didConnect peripheral: CBPeripheral)
    func diagnosticsService(_ diagnosticsService: KYDiagnosticsService, didFail peripheral: CBPeripheral)
    func diagnosticsService(_ diagnosticsService: KYDiagnosticsService, didDisconnect peripheral: CBPeripheral, error: Error?)
    func diagnosticsService(_ diagnosticsService: KYDiagnosticsService, didWriteValueFor characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral, error: Error?)
    func diagnosticsService(_ diagnosticsService: KYDiagnosticsService, didEndProcess peripheral: CBPeripheral, mcuIssue: String?, gaugeIssue: String?, gpsIssue: String?, cellularIssue: String?, displayIssue: String?, accelerometerIssue: String?, altimeterIssue: String?, eepromIssue: String?, diagnosticsIssue: Bool)
}

private let diagnosticsCharacteristicUUID = CBUUID(string:"A045")     // Run / Get Diagnostics
private let normalServiceUUID = CBUUID(string:"A030")               // Normal Service //TODO: check with GP to create new FOTA Service

class KYDiagnosticsService: NSObject, KYBluetoothCentralDelegate, KYBluetoothCentralWritable, KYBluetoothCentralReadable {
    
//    var ioc_firmwareController : KYFirmwareControllerProtocol!
//    var ioc_collarController : KYCollarControllerProtocol!
    
    fileprivate var diagnosticsCharacteristic : CBCharacteristic?
    private var bluetooth : KYBluetooth?
    var manager: CBCentralManager?
    var currentPeripheral: CBPeripheral?
    var discoveredPeripherals: [CBPeripheral]?
    var characteristicToWrite: CBCharacteristic?
    var characteristicsFound: [CBCharacteristic]?
//    var collar : KYCollar?
//    weak var cache: Cacheable?
    var delegate: DiagnosticsServiceProtocol?
    var scanTimer : Timer?
    private let scanTimeout = 30.0 //seconds
    private let scanLimitCounter = 3 // TODO: allow 3 times before disconnect
    private var scanFailCounter: Int = 0 //TODO: Int might be not needed
    private let delayToDiscoverServices = DispatchTimeInterval.seconds(2)
    
    fileprivate var didWriteDiagnosticsValue: Bool = false
    fileprivate var didReadDiagnosticsValue: Bool = false
    fileprivate var didReadDiagnosticsData: Bool = false
    fileprivate var didReadDiagnosticsIssue: Bool = false
    fileprivate var mcuIssueLabel = ""
    fileprivate var gaugeIssueLabel = ""
    fileprivate var gpsIssueLabel = ""
    fileprivate var cellularIssueLabel = ""
    fileprivate var displayIssueLabel = ""
    fileprivate var accelerometerIssueLabel = ""
    fileprivate var altimeterIssueLabel = ""
    fileprivate var eepromIssueLabel = ""
    
    var package: FADiagnosticsPackage!
    //    lazy var totalDiagnosticsData:[KYDiagnosticsData] = { //TODO: keep this one for future use when we are going to add them to the backend
    //        return []
    //    }()
    
    //MARK: Connectivity process
    func start(delegate: DiagnosticsServiceProtocol?) {
        self.delegate = delegate
        bluetooth = KYBluetooth(manager: .centralManager, serviceUUID: serviceUUID, characteristicsUUID: characteristicsUUID, centralDelegate: self, writableDelegate: self, readableDelegate: self)
    }
    
    private func startScanTimer() {
        DispatchQueue.main.async {
            if (self.scanTimer == nil) {
                self.scanTimer = Timer.scheduledTimer(timeInterval: self.scanTimeout, target: self, selector: #selector(self.scanTimeoutFired), userInfo: nil, repeats: false)
            }
        }
    }
    
    private func stopScanTimer() {
        DispatchQueue.main.async {
            if self.scanTimer != nil {
                self.scanTimer?.invalidate()
                self.scanTimer = nil
            }
        }
    }
    
    @objc private func scanTimeoutFired() {
        //TODO: we used to check here the scanCounter
        // Also we alert the user if counter limit was reached and decide what to do next.
        if let peripheral = currentPeripheral {
            self.scanTimer = nil
            bluetooth?.cancelPeripheralConnection(peripheral: peripheral)
        }
        else {
            bluetooth?.stopScan()
        }
    }
    
    func startScan() {
        bluetooth?.startScan()
    }
    
    func stopScan() {
        bluetooth?.stopScan()
    }
    
    func connectTo(peripheral: CBPeripheral)
    {
        bluetooth?.connectTo(peripheral: peripheral)
    }
    
    func cancel(peripheral: CBPeripheral)
    {
        bluetooth?.cancelPeripheralConnection(peripheral: peripheral)
        bluetooth?.tearDown()
    }
    
    func discoverServices(peripheral: CBPeripheral)
    {
        bluetooth?.discoverServices(peripheral: peripheral)
    }
    
    func writeData(isSucess:Bool) { //TODO: not using it update with the update values accordnigly
        
        // Data to write depending of the web request
        let data = self.data(isSuccess:isSucess)
        
        if let characteristic = self.characteristicToWrite {
            self.bluetooth?.writeValue(characteristic: characteristic, data: data)
        }
    }
    
    //MARK: - KYBluetoothCentralDelegate listeners
    func bluetooth(_ bluetooth: KYBluetooth, didChange state: TieraManagerState) {
        if state == .TieraManagerStatePoweredOn {
            // Process with scanning
            startScan()
            // add a timeout timer
            startScanTimer()
            // TODO: not sure if we need the counter after all
            scanFailCounter += 1
        }
        if state == .TieraManagerStatePoweredOff {
            if (self.scanFailCounter >= self.scanLimitCounter)
            {
                stopScan()
                // We used to cancelPeripheral and nil the manager, i think it will not needed here
                // Notify the UI based on the state to alert and return to the inventory
                delegate?.diagnosticsService(self, didChange: state)
            }
        }
    }
    
    func bluetooth(_ bluetooth: KYBluetooth, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        stopScanTimer()
        discoveredPeripherals? = [peripheral] // save a local copy of the peripherals found so CoreBT does not get rid of it
        
        // Notify KYBT for the relevant BT and nil timeout timer
        let discoveredSerialNumber = ""//NSString.ky_collarSerialNumber(fromPeripheralName: peripheral.name)
        if (discoveredSerialNumber == "" ){ //collar?.serialNumber) {
            print("DIAGNOSTICS_S: didDiscover peripheral - \(String(describing: discoveredSerialNumber))")
            scanFailCounter += 1//TODO: check if we need this one here
            self.bluetooth?.stopScan()
            self.bluetooth?.connectTo(peripheral: peripheral)
            currentPeripheral = peripheral // Save it for further use i.e. force disc or counter etc
        }
        else {
            print("DIAGNOSTICS_S: Could not find collar's SN")
        }
    }
    
    func bluetooth(_ bluetooth: KYBluetooth, didConnect peripheral: CBPeripheral) {
        print("DIAGNOSTICS_S: didConnect")
        Thread.sleep(forTimeInterval: 1.0) // This is needed to provide enough time between connection and discover services.
        
        // Notify the VIEW for the UI Changes collar connected
        delegate?.diagnosticsService(self, didConnect: peripheral)
        
        // Notify KYBT to discoverServices and discoverCharacteristics
        // The reason we wait 2 seconds is that PIC might went for Sleep and then needs time to reset.
        DispatchQueue.main.asyncAfter(deadline: .now() + delayToDiscoverServices) {
            self.bluetooth?.discoverServices(peripheral: peripheral)
        }
    }
    
    func bluetooth(_ bluetooth: KYBluetooth, didFail peripheral: CBPeripheral) {
        print("DIAGNOSTICS_S: didFail connect to peripheral")
        // Notify KYBT when failed to re-connectToPeripheral
        self.bluetooth?.connectTo(peripheral: peripheral)
    }
    
    func bluetooth(_ bluetooth: KYBluetooth, didDiscover characteristics:[CBCharacteristic], error: Error?) {
        // keep this array to use it in other methods
        // that do not obtain all char and it will not require a reconnect
        characteristicsFound = characteristics
        
        if didWriteDiagnosticsValue {
            print("DIAGNOSTICS_S: didDiscover characteristics didReadDiagnosticsValue true")
            for char in characteristicsFound! {
                if char.uuid == diagnosticsCharacteristicUUID { // A045
                    didWriteDiagnosticsValue = true
                    Thread.sleep(forTimeInterval: 30)
                    self.bluetooth?.readValue(characteristic: char)
                }
            }
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == diagnosticsCharacteristicUUID {
                diagnosticsCharacteristic = characteristic
                if let diagnosticsCharacteristic = diagnosticsCharacteristic {
                    let writeData : [UInt8] = []
                    print("DIAGNOSTICS_S: didDiscover characteristics writeData - \(String(describing: writeData))")
                    self.bluetooth?.writeValue(characteristic: diagnosticsCharacteristic, data: Data(bytes:writeData))
                    break
                }
            }
        }
        
    }
    
    //MARK: - KYBluetoothWritable listeners
    func bluetooth(_ bluetooth: KYBluetooth, didWriteValueFor characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral, error: Error?) {
        for char in characteristicsFound! {
            if char.uuid == diagnosticsCharacteristicUUID { // A045
                print("DIAGNOSTICS_S: didWriteValueFor Data char  \(String(describing: characteristic.uuid))")
                didReadDiagnosticsValue = true
                delegate?.diagnosticsService(self, didWriteValueFor: characteristic, forPeripheral: peripheral, error: error)
                
                //provide a short delay in order for the Collar to collect the neccessary diagnostics info
                Thread.sleep(forTimeInterval: 30)
                self.bluetooth?.readValue(characteristic: char)
            }
        }
    }
    
    //MARK: didUpdateValueForCharacteristic
    func bluetooth(_ bluetooth: KYBluetooth, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("DIAGNOSTICS_S: didUpdateValueFor for char \(characteristic)")
        guard let data = characteristic.value else {
            print ("DIAGNOSTICS_S: The caracteristics are not 90/46 length ")
            invalidData()
            return
        }
        let blockId :UInt8 = data.subdata(in: 0 ..< 1).withUnsafeBytes { $0.pointee }
        let payloadLength :UInt8 = data.subdata(in: 1 ..< 2).withUnsafeBytes { $0.pointee }
        
        if (package == nil){
            package = FADiagnosticsPackage(characteristic: characteristic, data: data)
        }
        package.data = data
        
        if payloadLength == 0 {
            print ("DIAGNOSTICS_S: payloadLength is zero ")
            invalidData()
            return
        }
        else {
            
            // When blockId = 1 we read bytes
            if (blockId == 1) {
                print ("DIAGNOSTICS_S: blockId 1 send readValue")
                package.totalData.append(package.data)//88 bytes
                Thread.sleep(forTimeInterval: 0.1)
                self.bluetooth?.readValue(characteristic: characteristic)
                return
            }
            else
                if (blockId == 0) { //last block - Block = 0
                    package.totalData.append(package.data)//44 bytes
                    print ("DIAGNOSTICS_S: Total data : \(package.totalData) with length : \(package.totalData.count)")
                    
                    splitDiagnosticsDataToPackage(diagnosticsData: package.totalData)
            }
        }
        
        //        readToUpload()//TODO: keep it
    }
    
    func splitDiagnosticsDataToPackage(diagnosticsData: Data) {
        if let mcuBytes =  diagnosticsData.subdata(in: 2..<7) as NSData? {
            package.mcuBytes = mcuBytes as Data
            let mcuIsWorkingByte :UInt32 = diagnosticsData.subdata(in: 6 ..< 7).withUnsafeBytes { $0.pointee }
            if mcuIsWorkingByte != 1 {
                mcuIssueLabel = "MC"
                didReadDiagnosticsIssue = true
            }
        }
        
        if let gaugeBytes =  diagnosticsData.subdata(in: 7..<15) as NSData? {
            package.gaugeBytes = gaugeBytes as Data
            let gaugeIsWorkingByte :UInt32 = diagnosticsData.subdata(in: 14 ..< 15).withUnsafeBytes { $0.pointee }
            if gaugeIsWorkingByte != 1 {
                gaugeIssueLabel = "GA"
            }
        }
        
        let gpsBytes : UInt32 = diagnosticsData.subdata(in: 15 ..< 16).withUnsafeBytes { $0.pointee }
        package.gpsBytes = gpsBytes
        if gpsBytes != 1 {
            gpsIssueLabel = "GP"
            didReadDiagnosticsIssue = true
        }
        
        if let cellularBytes =  diagnosticsData.subdata(in: 16..<78) as NSData? {
            package.cellularBytes = cellularBytes as Data
            let cellularIsWorkingByte :UInt32 = diagnosticsData.subdata(in: 77 ..< 78).withUnsafeBytes { $0.pointee }
            if cellularIsWorkingByte != 1 {
                cellularIssueLabel = "CE"
                didReadDiagnosticsIssue = true
            }
        }
        
        if let displayBytes =  diagnosticsData.subdata(in: 78..<129) as NSData? {
            package.displayBytes = displayBytes as Data
            let displayIsWorkingByte :UInt32 = diagnosticsData.subdata(in: 128 ..< 129).withUnsafeBytes { $0.pointee }
            if displayIsWorkingByte != 1 {
                displayIssueLabel = "DI"
                didReadDiagnosticsIssue = true
            }
        }
        
        if let accelerometerBytes =  diagnosticsData.subdata(in: 129..<131) as NSData? {
            package.accelerometerBytes = accelerometerBytes as Data
            let accelerometerIsWorkingByte :UInt32 = diagnosticsData.subdata(in: 130 ..< 131).withUnsafeBytes { $0.pointee }
            if accelerometerIsWorkingByte != 1 {
                accelerometerIssueLabel = "AC"
                didReadDiagnosticsIssue = true
            }
        }
        
        if let altimeterBytes =  diagnosticsData.subdata(in: 131..<134) as NSData? {
            package.altimeterBytes = altimeterBytes as Data
            let altimeterIsWorkingByte :UInt32 = diagnosticsData.subdata(in: 133 ..< 134).withUnsafeBytes { $0.pointee }
            if altimeterIsWorkingByte != 1 {
                altimeterIssueLabel = "AL"
                didReadDiagnosticsIssue = true
            }
        }
        
        if let eepromBytes =  diagnosticsData.subdata(in: 134..<136) as NSData? {
            package.eepromBytes = eepromBytes as Data
            let eepromIsWorkingByte :UInt32 = diagnosticsData.subdata(in: 135 ..< 136).withUnsafeBytes { $0.pointee }
            if eepromIsWorkingByte != 1 {
                eepromIssueLabel = "EE"
                didReadDiagnosticsIssue = true
            }
        }
        
        didReadDiagnosticsData = true
        //Call the View to inform the UI for the completion of the diagnostics process
        delegate?.diagnosticsService(self, didEndProcess: currentPeripheral!, mcuIssue: mcuIssueLabel, gaugeIssue: gaugeIssueLabel, gpsIssue: gpsIssueLabel, cellularIssue: cellularIssueLabel, displayIssue: displayIssueLabel, accelerometerIssue: accelerometerIssueLabel, altimeterIssue: altimeterIssueLabel, eepromIssue: eepromIssueLabel, diagnosticsIssue: didReadDiagnosticsIssue)
    }
    
    func readToUpload() {
        
        if (didReadDiagnosticsData) {
            print ("DIAGNOSTICS_S: readToUpload")
            didReadDiagnosticsData = false
        }
        else {
            print ("DIAGNOSTICS_S: !didReadAccelerometerData")
        }
    }
    
    func invalidData() {
        //        petStatus.diagnosticsData = []
        print ("DIAGNOSTICS_S: === InvalidData - Wrong data with totalBytes : \(String(describing: package.totalData))")
        didReadDiagnosticsData = true
        readToUpload()
    }
    
    //MARK: Disconnected
    func bluetooth(_ bluetooth: KYBluetooth, didDisconnect peripheral: CBPeripheral, error: Error?) {
        if didWriteDiagnosticsValue { // use the following in case of an abnormal disc
            print("DIAGNOSTICS_S: didDisconnect - reconnect ")
            self.bluetooth?.connectTo(peripheral: peripheral)
        }
        
        if didReadDiagnosticsValue {
            print("DIAGNOSTICS_S: didDisconnect - didReadDiagnosticsValue ")
        }
        print("DIAGNOSTICS_S: end of didDisconnect - reconnect ")
    }
    
    /*End Of Class*/
}

extension KYDiagnosticsService: BluetoothService {
    
    var characteristicsUUID: [CBUUID]{
        return [diagnosticsCharacteristicUUID]
    }
    
    var serviceUUID: CBUUID {
        return normalServiceUUID
    }
    
    // - Registration Status = 0x0A or 10d means success.
    // - Registration Status = 0x9A or 154d means failure.
    func data(isSuccess: Bool) -> Data{
        
        let bytes :[UInt8] = isSuccess ? [0x01] : [0x00]
        return Data(bytes:bytes)
    }
    
}
