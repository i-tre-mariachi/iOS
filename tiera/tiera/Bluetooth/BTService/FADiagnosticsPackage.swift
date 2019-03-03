//
//  FADiagnosticsPackage.swift
//  tiera
//
//  Created by Christos Christodoulou on 03/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import Foundation
import CoreBluetooth

class FADiagnosticsPackage{
    
    var data: Data
    var totalData: Data
    var mcuBytes: Data?
    var gaugeBytes: Data?
    var gpsBytes: UInt32?
    var cellularBytes: Data?
    var displayBytes: Data?
    var accelerometerBytes: Data?
    var altimeterBytes: Data?
    var eepromBytes: Data?
    
    let characteristic: CBCharacteristic
    
    init?(characteristic: CBCharacteristic, data: Data){
        self.characteristic = characteristic
        self.data = data
        self.totalData = Data()
    }
}
