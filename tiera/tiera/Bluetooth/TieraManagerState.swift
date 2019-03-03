//
//  TieraManagerState.swift
//  tiera
//
//  Created by Christos Christodoulou on 03/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//
import Foundation

public enum TieraManagerState: Int {
    case TieraManagerStateUnknown = 0
    case TieraManagerStateResetting = 1
    case KYManagerStateUnsupported = 2
    case TieraManagerStateUnauthorized = 3
    case TieraManagerStatePoweredOff = 4
    case TieraManagerStatePoweredOn = 5

}
