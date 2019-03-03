//
//  FABluetoothServiceProtocol.swift
//  tiera
//
//  Created by Christos Christodoulou on 03/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import Foundation
import CoreBluetooth

/// This protocol require to set the serviceUUID and an array of characteristicUUID of the peripheral you wish to interact (read/write).
protocol BluetoothService
{
    var serviceUUID: CBUUID {get}
    var characteristicsUUID: [CBUUID] {get}
}
